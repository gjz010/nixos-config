#!/usr/bin/env -S deno run --allow-all
import { parseArgs } from "jsr:@std/cli/parse-args";
import { exists, walk } from "https://deno.land/std@0.224.0/fs/mod.ts";
import { resolve } from "https://deno.land/std@0.224.0/path/mod.ts";
import { basename, dirname, relative } from "node:path";

const allowed_flags = [
    "help",
    "check",
    "encrypt",
    "decrypt",
    "nonew",
] as const;
const decrypted_root = "./.secrets-embedded";
const encrypted_root = "./secrets/embedded";
const ignored_files = [".gitignore", ".gitkeep", "README.md"];

type Path = [dir: string, file: string];
async function* listFilesInFolder(
    root: string,
): AsyncGenerator<Path> {
    for await (const entry of walk(root, { canonicalize: true })) {
        if (entry.isFile && !ignored_files.includes(entry.name)) {
            const rel = relative(root, entry.path);
            yield [dirname(rel), basename(rel)];
        }
    }
}
type Pair = [encrypted: string, decrypted: string];
async function listEncryptedFiles(): Promise<Pair[]> {
    const xs: Pair[] = [];
    for await (const [dir, file] of listFilesInFolder(encrypted_root)) {
        xs.push([
            resolve(encrypted_root, dir, file),
            resolve(decrypted_root, dir, file),
        ]);
    }
    return xs;
}
async function listDecryptedFiles(): Promise<Pair[]> {
    const xs: Pair[] = [];
    for await (const [dir, file] of listFilesInFolder(decrypted_root)) {
        xs.push([
            resolve(encrypted_root, dir, file),
            resolve(decrypted_root, dir, file),
        ]);
    }
    return xs;
}
//console.log(await listEncryptedFiles());
//console.log(await listDecryptedFiles());
const configFlags = ["--config", resolve(Deno.cwd(), ".sops.yaml")];
async function encryptAllFiles(nonew: boolean) {
    let success = true;
    for (const [e, d] of await listDecryptedFiles()) {
        if (!await exists(e)) {
            console.log(`Encrypting ${e} <- ${d} (new)`);
            const subproc = new Deno.Command("sops", {
                args: [...configFlags, "encrypt", "--filename-override", e, d],
                stdout: "piped",
            });
            const s = subproc.spawn();
            const stdout = await s.output();
            const st = await s.status;

            /*
            if (!st.success) {
                console.error(`Error encrypting ${e} <- ${d}`);
                Deno.exit(2);
            }
            */
            if (nonew) {
                /*
                const stdout = await s.output();
                await Deno.writeFile(e, stdout.stdout);
                await new Deno.Command("git", {
                    args: [
                        "add",
                        e,
                        "--intent-to-add",
                    ],
                }).spawn().status;
                */
                console.log(`Nonew specified. Ignored.`);
                success = false;
            } else {
                await Deno.writeFile(e, stdout.stdout);
                await new Deno.Command("git", {
                    args: [
                        "add",
                        e,
                    ],
                }).spawn().status;
            }
        } else {
            console.log(`Encrypting ${e} <- ${d} (update)`);
            const subproc = new Deno.Command("sops", {
                args: [...configFlags, "edit", e],
                env: {
                    EDITOR: `cp \"${d}\"`,
                },
            });
            const s = subproc.spawn();
            await s.status;
        }
    }
    return success;
}
async function decryptAllFiles() {
    for (const [e, d] of await listEncryptedFiles()) {
        console.log(`Decrypting ${e} -> ${d}`);
        const subproc = new Deno.Command("sops", {
            stdout: "piped",
            args: [...configFlags, "decrypt", e],
        });
        const s = subproc.spawn();
        await s.status;
        const stdout = await s.output();
        await Deno.writeFile(d, stdout.stdout);
    }
}
function printHelp() {
    console.log("Usage: secrets-embedded [option]");
    console.log("Options:");
    console.log("  --help           Print this help message");
    console.log("  --encrypt        Encrypt the secrets.");
    console.log("  --decrypt        Decrypt the secrets");
    console.log("  --nonew          Do not create new files");
}
async function main() {
    console.log(Deno.cwd());

    const flags = parseArgs(Deno.args, {
        boolean: allowed_flags,
    });
    if (flags.help) {
        return printHelp();
    }
    if (
        Number(flags.check) + Number(flags.encrypt) + Number(flags.decrypt) +
                    Number(flags.help) !== 1 || flags._.length
    ) {
        console.error("Invalid arguments");
        printHelp();
        Deno.exit(1);
    }
    if (flags.encrypt) {
        const s = await encryptAllFiles(flags.nonew);
        if (!s) {
            console.log(
                "New file detected while encrypting. Please stage them.",
            );
            Deno.exit(1);
        }
    } else if (flags.decrypt) {
        await decryptAllFiles();
    }
}

if (import.meta.main) {
    await main();
}

import typescript from "@rollup/plugin-typescript";
import autoExternal from "rollup-plugin-auto-external";
import shebang from "rollup-plugin-shebang-bin";
export default {
  input: "bin/index.ts",
  output: {
    dir: "build/bin",
    format: "cjs",
  },
  plugins: [
    typescript(),
    autoExternal(),
    shebang({
      include: ["**/*.ts", "**/*.js"],
    }),
  ],
};

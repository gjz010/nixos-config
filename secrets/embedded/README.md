# Embedded secrets

These secrets are encrypted/decrypted upon git commit/checkout.

In other words, they will appear as plain text in Nix store.

Suitable for:

- Configurations that are secret for the public but never a secret for machine, e.g. public server addresses, internal network configuration, etc.
- Secrets that are hard to integrate into existing NixOS modules.

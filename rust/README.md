## Project setup for Rust dev
Source: [5 Better ways to code in Rust by Let's Get Rusty](https://www.youtube.com/watch?v=BU1LYFkpJuk)
- Code completion, go to definition, etc: [rust-analyzer extension](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer) and its [language server](https://rust-analyzer.github.io/)
- Debugging: [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb)
- TOML files syntax highlighting: [Better TOML](https://marketplace.visualstudio.com/items?itemName=bungcip.better-toml)
- Better error reporting in the editor (useful for anything, not just Rust): [Error Lens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens)
- Report when any of the dependencies in `Cargo.toml` are out of date: [crates](https://marketplace.visualstudio.com/items?itemName=serayuzgur.crates)

### Formatting and linting
Configure VSCode using the following config:
```json
{
  "rust-analyzer.check.command": "clippy",
  "[rust]": {
    "editor.defaultFormatter": "rust-lang.rust-analyzer",
    "editor.formatOnSave": true,
  }
}
```

## Useful cargo plugins
- [cargo-watch](https://crates.io/crates/cargo-watch)
- [cargo-sqlx](https://crates.io/crates/cargo-sqlx)
- [cargo-expand](https://crates.io/crates/cargo-expand)
- [cargo-sweep](https://crates.io/crates/cargo-sweep)

# sshmenu

A tiny Bash script that shows your SSH hosts in a simple `whiptail` menu and connects to the one you pick.

## Features

- Reads `${HOME}/.ssh/config`
- Interactive menu with styled colors
- Just pick a host and it runs `ssh <host>`

## Usage

1. Make it executable:
```bash
   chmod +x sshmenu.sh
````

2. (Optional) Move to your `$PATH`:

```bash
   sudo mv sshmenu.sh /usr/local/bin/sshmenu
```

3. Run:

```bash
   sshmenu
```

---

## Example

Your `~/.ssh/config` might look like:

```
Host myserver
    HostName 192.168.1.10
    User root

Host devbox
    HostName dev.example.com
    User vince
```

Running `sshmenu` would show a nice menu like:

```
┌──═ myserver
├──═ devbox
└──< Quit
```

---

## Notes

* Only top-level `Host` entries are listed (wildcards and Match blocks are skipped).
* If no config is found or readable, nothing is shown.
* Menu styling is defined in the script using your custom `change_colors` function (can be tweaked as needed).

---

## License

MIT — do whatever you want.

---

## Author

[vinniev (SingleDraw)](https://github.com/SingleDraw)

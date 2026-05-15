# WezTerm Color Schemes

Source: <https://wezterm.org/colorschemes/index.html>

WezTerm ships with over 1000 built-in color schemes. Set one with:

```lua
config.color_scheme = 'Catppuccin Mocha'
```

The string must match the scheme name exactly (case and spaces matter).

## Popular dark schemes

| Name | Vibe |
|---|---|
| `Catppuccin Mocha` | Warm pastel dark, very popular |
| `Catppuccin Macchiato` | Slightly lighter Catppuccin |
| `Catppuccin Frappe` | Mid-tone Catppuccin |
| `Tokyo Night` | Cool blues, modern |
| `Tokyo Night Storm` | Tokyo Night with deeper background |
| `Gruvbox Dark` | Retro warm earth tones |
| `Gruvbox Material (Gogh)` | Softer Gruvbox |
| `Dracula` | High-contrast purple/pink classic |
| `Dracula (Gogh)` | Gogh variant |
| `Nord` | Arctic blues, low contrast |
| `OneDark` | Atom-inspired |
| `Solarized Dark` | Ethan Schoonover classic |
| `Solarized Dark (Gogh)` | Slight variant |
| `Kanagawa (Gogh)` | Japanese woodblock palette |
| `Rose Pine` | Muted warm pastels |
| `Rose Pine Moon` | Cooler Rose Pine |

## Popular light schemes

| Name | Vibe |
|---|---|
| `Catppuccin Latte` | Pastel light |
| `Solarized Light` | Classic light |
| `Tokyo Night Day` | Light Tokyo Night |
| `Github (Gogh)` | GitHub-style light |
| `Gruvbox light` | Warm light |

## Discovering more

```bash
# List every scheme name your binary knows
wezterm ls-fonts          # (no, this is fonts — see below)
```

For schemes, the canonical list is the website, but you can also enumerate them in Lua:

```lua
local schemes = wezterm.color.get_builtin_schemes()
for name, _ in pairs(schemes) do
  wezterm.log_info(name)
end
```

Log output appears in the debug overlay (`Ctrl+Shift+L`).

## Switching at runtime

Bind a key that cycles between two schemes:

```lua
local appearance = 'dark'
config.keys = {
  { key = 'F2', action = wezterm.action_callback(function(window)
      appearance = (appearance == 'dark') and 'light' or 'dark'
      local overrides = window:get_config_overrides() or {}
      overrides.color_scheme = (appearance == 'dark') and 'Catppuccin Mocha' or 'Catppuccin Latte'
      window:set_config_overrides(overrides)
  end) },
}
```

## Custom colors

Override individual colors without picking a scheme:

```lua
config.colors = {
  foreground = '#cdd6f4',
  background = '#1e1e2e',
  cursor_bg  = '#f5e0dc',
  cursor_fg  = '#1e1e2e',
  selection_bg = '#585b70',
  ansi = { '#45475a', '#f38ba8', '#a6e3a1', '#f9e2af',
           '#89b4fa', '#f5c2e7', '#94e2d5', '#bac2de' },
  brights = { '#585b70', '#f38ba8', '#a6e3a1', '#f9e2af',
              '#89b4fa', '#f5c2e7', '#94e2d5', '#a6adc8' },
}
```

If both `color_scheme` and `colors` are set, `colors` wins per-field.

config.load_autoconfig(False)

# Rose Pine Moon palette.
base = "#232136"
surface = "#2a273f"
overlay = "#393552"
muted = "#6e6a86"
subtle = "#908caa"
text = "#e0def4"
love = "#eb6f92"
gold = "#f6c177"
rose = "#ea9a97"
pine = "#3e8fb0"
foam = "#9ccfd8"
iris = "#c4a7e7"
highlight_low = "#2a283e"
highlight_med = "#44415a"
highlight_high = "#56526e"

# Core browser behavior.
c.auto_save.session = True
c.content.pdfjs = True
c.confirm_quit = ["downloads"]
c.downloads.location.directory = "~/Downloads"
c.editor.command = ["nvim", "{file}"]
c.scrolling.smooth = True
c.url.default_page = "about:blank"
c.url.start_pages = ["about:blank"]
c.content.user_stylesheets = ["~/.config/qutebrowser/styles/user.css"]

# Vertical tabs.
c.tabs.position = "left"
c.tabs.width = "14%"
c.tabs.show = "always"
c.tabs.title.alignment = "left"
c.tabs.title.elide = "right"
c.tabs.title.format = "{audio}{index}: {current_title}"
c.tabs.title.format_pinned = "{index}"
c.tabs.favicons.show = "always"
c.tabs.padding = {"top": 5, "bottom": 5, "left": 8, "right": 8}
c.tabs.indicator.width = 2
c.tabs.select_on_remove = "last-used"
c.tabs.last_close = "close"

# Ad blocking. With your current install this uses hosts blocking; installing the
# optional Python adblock package enables Brave/ABP filtering automatically.
c.content.blocking.enabled = True
c.content.blocking.method = "auto"
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://secure.fanboy.co.nz/fanboy-annoyance.txt",
    "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt",
]
c.content.blocking.hosts.lists = [
    "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts",
]

# Rose Pine Moon colors.
c.colors.webpage.bg = base

c.colors.completion.fg = text
c.colors.completion.odd.bg = base
c.colors.completion.even.bg = surface
c.colors.completion.category.fg = foam
c.colors.completion.category.bg = base
c.colors.completion.category.border.top = base
c.colors.completion.category.border.bottom = overlay
c.colors.completion.item.selected.fg = text
c.colors.completion.item.selected.bg = overlay
c.colors.completion.item.selected.border.top = iris
c.colors.completion.item.selected.border.bottom = iris
c.colors.completion.item.selected.match.fg = gold
c.colors.completion.match.fg = gold
c.colors.completion.scrollbar.fg = iris
c.colors.completion.scrollbar.bg = base

c.colors.contextmenu.menu.bg = base
c.colors.contextmenu.menu.fg = text
c.colors.contextmenu.selected.bg = overlay
c.colors.contextmenu.selected.fg = text
c.colors.contextmenu.disabled.bg = base
c.colors.contextmenu.disabled.fg = muted

c.colors.downloads.bar.bg = base
c.colors.downloads.start.fg = base
c.colors.downloads.start.bg = pine
c.colors.downloads.stop.fg = base
c.colors.downloads.stop.bg = foam
c.colors.downloads.error.fg = love

c.colors.hints.fg = base
c.colors.hints.bg = gold
c.colors.hints.match.fg = love

c.colors.keyhint.fg = text
c.colors.keyhint.suffix.fg = gold
c.colors.keyhint.bg = surface

c.colors.messages.error.fg = text
c.colors.messages.error.bg = love
c.colors.messages.error.border = love
c.colors.messages.info.fg = text
c.colors.messages.info.bg = surface
c.colors.messages.info.border = overlay
c.colors.messages.warning.fg = base
c.colors.messages.warning.bg = gold
c.colors.messages.warning.border = gold

c.colors.prompts.fg = text
c.colors.prompts.border = f"1px solid {iris}"
c.colors.prompts.bg = surface
c.colors.prompts.selected.bg = overlay

c.colors.statusbar.normal.fg = text
c.colors.statusbar.normal.bg = base
c.colors.statusbar.insert.fg = base
c.colors.statusbar.insert.bg = foam
c.colors.statusbar.passthrough.fg = base
c.colors.statusbar.passthrough.bg = iris
c.colors.statusbar.private.fg = text
c.colors.statusbar.private.bg = overlay
c.colors.statusbar.command.fg = text
c.colors.statusbar.command.bg = surface
c.colors.statusbar.command.private.fg = text
c.colors.statusbar.command.private.bg = overlay
c.colors.statusbar.caret.fg = base
c.colors.statusbar.caret.bg = rose
c.colors.statusbar.caret.selection.fg = base
c.colors.statusbar.caret.selection.bg = gold
c.colors.statusbar.progress.bg = iris
c.colors.statusbar.url.fg = text
c.colors.statusbar.url.error.fg = love
c.colors.statusbar.url.hover.fg = iris
c.colors.statusbar.url.success.http.fg = pine
c.colors.statusbar.url.success.https.fg = foam
c.colors.statusbar.url.warn.fg = gold

c.colors.tabs.bar.bg = base
c.colors.tabs.indicator.start = iris
c.colors.tabs.indicator.stop = foam
c.colors.tabs.indicator.error = love
c.colors.tabs.indicator.system = "rgb"
c.colors.tabs.odd.fg = subtle
c.colors.tabs.odd.bg = base
c.colors.tabs.even.fg = subtle
c.colors.tabs.even.bg = highlight_low
c.colors.tabs.selected.odd.fg = text
c.colors.tabs.selected.odd.bg = overlay
c.colors.tabs.selected.even.fg = text
c.colors.tabs.selected.even.bg = overlay
c.colors.tabs.pinned.odd.fg = gold
c.colors.tabs.pinned.odd.bg = base
c.colors.tabs.pinned.even.fg = gold
c.colors.tabs.pinned.even.bg = highlight_low
c.colors.tabs.pinned.selected.odd.fg = base
c.colors.tabs.pinned.selected.odd.bg = gold
c.colors.tabs.pinned.selected.even.fg = base
c.colors.tabs.pinned.selected.even.bg = gold

# Vim/Neovim-like navigation and leader-style bindings.
config.bind("<Ctrl-j>", "tab-next")
config.bind("<Ctrl-k>", "tab-prev")
config.bind("<Ctrl-h>", "back")
config.bind("<Ctrl-l>", "forward")
config.bind("<Alt-j>", "tab-next")
config.bind("<Alt-k>", "tab-prev")
config.bind("<Ctrl-d>", "scroll-page 0 0.5")
config.bind("<Ctrl-u>", "scroll-page 0 -0.5")
config.bind("<Escape>", "clear-keychain ;; search ;; fullscreen --leave")

# Space leader binds, matching the shape of the Neovim config where possible.
config.bind("<Space>pv", "cmd-set-text -s :open file:///home/veya/")
config.bind("<Space>e", "cmd-set-text -s :open")
config.bind("<Space>q", "tab-close")
config.bind("<Space>k", "quit --save")
config.bind("<Space>r", "reload")
config.bind("<Space>R", "reload -f")
config.bind("<Space>y", "yank")

# Tab group workflow. qutebrowser does not have native named tab groups, so these
# use windows and named sessions as the closest browser-native equivalent.
config.bind("<Space>gs", "cmd-set-text -s :session-save --only-active-window ")
config.bind("<Space>gl", "cmd-set-text -s :session-load --clear ")
config.bind("<Space>gL", "cmd-set-text -s :session-load ")
config.bind("<Space>gp", "tab-pin")
config.bind("<Space>ga", "tab-give")
config.bind("<Space>gA", "tab-give --keep")
config.bind("<Space>gn", "tab-give")
config.bind("<Space>gm", "cmd-set-text -s :tab-move ")
config.bind("<Space>gJ", "tab-move +")
config.bind("<Space>gK", "tab-move -")
config.bind("<Space>g0", "tab-move start")
config.bind("<Space>g$", "tab-move end")
config.bind("<Space>gj", "tab-focus stack-next")
config.bind("<Space>gk", "tab-focus stack-prev")

# Keep the normal qutebrowser tab keys too.
config.bind("J", "tab-next")
config.bind("K", "tab-prev")
config.bind("gJ", "tab-move +")
config.bind("gK", "tab-move -")

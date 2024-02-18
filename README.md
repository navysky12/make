# dot

Designed for managing dotfiles spread across multiple repos by utilising [GNU stow](https://www.gnu.org/software/stow/) with limited link folding functionality for git submodules.

---

### makefile breakdown:
| `make target` | purpose                                   |
| -:            | :-                                        |
| `make work`   | generates `work/` directory               |
| `make clean`  | cleans `work/` directory                  |
| `make stow`   | stows `work/` directory to `${HOME}`      |
| `make unstow` | unstows `work/` directory from `${HOME}`  |

---

### Usage:

Place your dotfile repos/folders into same directory as dot's `makefile`:
```
dot/
├── priv_dotfiles.git/
│   ├── .config/
│   │   ├── app_priv/
│   │   |   └── app.conf
│   │   ├── submodule_priv.git/
│   │   |   └── ...
│   │   └── config_priv.txt
│   ├── .git
│   └── .gitmodules
├── pub_dotfiles.git/
│   ├── .config/
│   │   ├── app_pub/
│   │   |   └── init.lua
│   │   ├── submodule_pub.git/
│   │   |   └── ...
│   │   └── config_pub.lua
│   ├── .git
│   ├── .gitmodules
│   └── .profile
└── makefile
```

Run `make work`:
```
dot/
├── priv_dotfiles.git/
│   └── ... remains untouched
├── pub_dotfiles.git/
│   └── ... remains untouched
├── work/
│   ├── .config/
│   │   ├── app_priv/
│   │   |   └── app.conf -> ../../../pub_dotfiles.git/.config/app_priv/app.conf
│   │   ├── app_pub/
│   │   |   └── init.lua -> ../../../pub_dotfiles.git/.config/app_pub/init.lua
│   │   ├── submodule_priv.git -> ../../priv_dotfiles.git/.config/submodule_priv.git
│   │   ├── submodule_pub.git -> ../../pub_dotfiles.git/.config/submodule_pub.git
│   │   ├── config_priv.txt -> ../../priv_dotfiles.git/.config/config_priv.txt
│   │   └── config_pub.lua -> ../../pub_dotfiles.git/.config/config_pub.lua
│   └── .profile -> ../pub_dotfiles.git/.profile
└── makefile
```
Note that the submodule repo directories have their whole folder linked to avoid excessive link creation.
`.git` is ignored by stow's native ignore lists and `.gitmodules` is ignored by dot's makefile submodule functionality.

Run `make stow`:
```
${HOME}/
├── .config/
│   ├── app_priv/
│   |   └── app.conf -> {relative path to dot/}/work/.config/app_priv/app.conf
│   ├── app_pub/
│   |   └── init.lua -> {relative path to dot/}/work/.config/app_pub/init.lua
│   ├── submodule_priv.git -> {relative path to dot/}/work/.config/submodule_priv.git
│   ├── submodule_pub.git -> {relative path to dot/}/work/.config/submodule_pub.git
│   ├── config_priv.txt -> {relative path to dot/}/work/.config/config_priv.txt
│   └── config_pub.lua -> {relative path to dot/}/work/.config/config_pub.lua
└── .profile -> {relative path to dot/}/work/.profile
```

The script is non destructive of files that already exist in `${HOME}` due to the nature of stow.

---


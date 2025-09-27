## dictionaries

### install sdcv

**linux**
`sudo pacman -S sdcv`
**mac**
`brew install sdcv`

### Create folder

**linux**
`mkdir -p /usr/share/stardict/dic/`
**mac**
`mkdir -p ${XDG_DATA_HOME}/stardict/dic`

> ${XDG_DATA_HOME} suitable for all which should be ${HOME}/.local/share

### Download Dicts

> [Dicts](https://web.archive.org/web/20200702000038/http://download.huzheng.org/)
> choose "朗道英汉字典5.0","jmdict-en-ja" for ch/jp -> en

### Tar the each dicts

`sudo tar -xvjf stardict-dictd_www.dict.org_gcide-2.4.2.tar.bz2 -C /usr/share/stardict/dic`

### Test For Check in userscripts, also be careful about the path

# •Sum•
__Void°Doctrine__ is a low-profile userdata observer, made to detect and log visible [vKontakte](https://vk.com) page changes on demand.  
Just specify a file with some ids/screennames or paste them in `feed.txt` to watch what people do when you don't look.  
__Latest version:__ https://github.com/Guevara-chan/Void-Doctrine/releases/download/0.1/Void.Doctrine.exe (direct link)

# •Featuræ•
* <u>No trust required</u>: __Void°Doctrine__ is completely agnostic about it's user, registering zero information beyond archive.
* No particular app dependence, stock [API tokens](https://vk.com/dev/access_token) can easily be overriden with `-t:<token>` argument.
* No need for account credentials, fetching mechanism is designed to work without auth.
* No installation, placing single executable to some writeable dir is enough.
* No external requirements beyond VC runtime.

# •Reassembling•
__Void°Doctrine__ has been entirelly made with [Nim 0.18.0](https://nim-lang.org) and external [VkApi](https://github.com/vk-brain/nimvkapi) package by VK Brain.  
Automated build script provided as `release.nims`.

# •Brief samples of interfacing•
![image](https://user-images.githubusercontent.com/8768470/44298045-a76d4700-a2e4-11e8-8dd1-19707265e83e.png)

# •Sum•
__Void°Doctrine__ is a low-profile userdata observer, made to detect and log visible [vKontakte](https://vk.com) page changes on demand.  
Just specify a file with some ids/screennames or paste them in `feed.txt` to watch what people do when you don't look.  
__Latest version:__ https://github.com/Guevara-chan/Void-Doctrine/releases/download/0.13/Void.Doctrine.exe (direct link)  
❗ [OpenSSL](https://github.com/openssl/openssl) [libraries](https://github.com/Guevara-chan/Void-Doctrine/releases/tag/lib) (already provided with Nim installation) needs to be placed in same dir with pre-compiler binaries. ❗

# •Featuræ•
* <u>No trust required</u>: __Void°Doctrine__ is completely agnostic about it's user, registering zero information beyond archive.
* No particular app dependence, stock [API token](https://vk.com/dev/access_token) can easily be overriden with `-t:<token>` argument.
* No need for account credentials, fetching mechanism is designed to work without auth.
* No installation, placing executable and auxiliary libs to some writeable dir is enough.

# •Reassembling•
__Void°Doctrine__ has been entirelly made with [Nim 0.19.0](https://nim-lang.org) and external [VkApi](https://github.com/vk-brain/nimvkapi) package by VK Brain.  
x86/x64 cross-compilation can be achieved through [TDM-GCC](http://tdm-gcc.tdragon.net/download) by automated build script provided as `release.nims`.

# •Brief samples of interfacing•
![image](https://user-images.githubusercontent.com/8768470/44452452-3ccb4c80-a5ff-11e8-9117-ff442670b4fc.png)

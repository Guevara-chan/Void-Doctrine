# •Sum•
__Void°Doctrine__ is a low-profile userdata observer, made to detect and log visible [vKontakte](https://vk.com) page changes on demand.  
Developed to be as standalone as possible, it's packed into single executable with stock service [API token](https://vk.com/dev/access_token) provided.  
Just specify a file with some ids/screennames or paste them in `feed.txt` to watch what people do beyond you.  
__Latest version:__ https://github.com/Guevara-chan/Void-Doctrine/releases/download/v0.1/Void-Doctrine.exe (direct link)

# •Featuræ•
* No account credentials required, fetching mechanism is designed to work without auth.
* No app dependence, other tokens can always be provided with `-t:<token>` argument.
* No installation, placing _Void°Doctrine.exe_ to some writeable dir is enough.
* No external requirements beyond VC runtime.

# •Reassembling•
__Void°Doctrine__ has been entirelly made with [Nim 0.18.0](https://nim-lang.org) and external [VkApi](https://github.com/vk-brain/nimvkapi) package by VK Brain.  
Automated build script provided as `release.nims`.

# •Brief samples of interfacing•
![image](https://user-images.githubusercontent.com/8768470/44298045-a76d4700-a2e4-11e8-8dd1-19707265e83e.png)

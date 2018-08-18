# •Sum•
__Void°Doctrine__ is a low-profile userdata observer, made to detect and log visible [vKontakte](https://vk.com) page changes on demand.  
Developed to be as standalone as possible, it's packed in single executable with stock service [API token](https://vk.com/dev/access_token) provided.  
Just specify a file with some ids/screennames or paste them in `feed.txt` to watch what people do beyond you.

# •Featuræ•
* No account credentials required, fetching mechanism is designed to work without auth.
* No app dependence, other tokens can always be provided with `-t:<token>` argument.
* No installation, placing _Void°Doctrine.exe_ to some writeable dir is enough.
* No external requirements beyond VC runtime.

# •Reassembling•
__Void°Doctrine__ has been entirelly made with [Nim 0.18.0](https://nim-lang.org) and external [VkApi](https://github.com/vk-brain/nimvkapi) package by VK Brain.  
Automated build script provided as `release.nims`.

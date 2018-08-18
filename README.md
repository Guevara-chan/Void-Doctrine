# •Sum•
__Void°Doctrine__ is a low-profile userdata observer, made to detect and log visible [vKontakte](https://vk.com) page changes on demand.  
Developed to be as inconspicuous as possible, it's packed in single executable with stock service [API token](https://vk.com/dev/access_token) provided.  
Just specify a file with some ids/screennames or paste them in `feed.txt` to watch what people do beyond you.

# •Featuræ•
* No online activity markers, fetching mechanism is designed to work without auth.
* No installation, placing _Void°Doctrine.exe_ to some writeable dir is enough.
* No account credentials required to work (stock token included).
* No external dependencies beyond VC runtime.

# •Reassembling•
__Void°Doctrine__ has been entirelly made with [Nim 0.18.0](https://nim-lang.org) and external [VkApi](https://github.com/vk-brain/nimvkapi) package by VK Brain.  
Automated build script provided as `release.nims`.

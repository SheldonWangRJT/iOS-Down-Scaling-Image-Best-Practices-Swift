# iOS-Down-Scaling-Image-Best-Practices-Swift

This project is created by Sheldon inspired by the article [here](https://mp.weixin.qq.com/s/PNj3JEoaDtFnSnjOAIEEqA). Big shout out the original author, he also has a repo for his article [here](https://github.com/woshiccm/ImageResizing/tree/master). But because the article was written in Chinese, so I will do some translation and add some addional info included from WWDC18.

This project is a summary of down-scaling images in 5 different ways. All 5 ways are all from iOS different native framework, which are:
- UIKit
- Core Graphics
- Image I/O
- Core Image
- vImage

Some of them are from higher level framework like UIKit, which results in simpler API and easier uasage, on the contrary, some of them are from more basic or lower level framework like vImage, which results in much more complex code writing.

Please checkout the implementation in the extension file I created under the repo [here](https://github.com/SheldonWangRJT/iOS-Down-Scaling-Image-Best-Practices-Swift/blob/master/Down-Scaling-Image/UIImage%2BExtension.swift).

I also made a video in Youtube [here](https://youtu.be/UpVFLuttVn4) to explain how they work and the relation with a of the very useful tutorial from this year's WWDC18 regarding the memory management of iOS [here](https://developer.apple.com/videos/play/wwdc2018/416/) and I also have written some notes about the video from WWDC18 [here](https://gist.github.com/SheldonWangRJT/5d2ea69f78a905c76e0c36dfc994e85c).

To use the extension file to down-scaling images, you can do: 
```swift
  newImage = image.resizeUI(size: desiredSize) // using UIKit
  newImage = image.resizeCG(size: desiredSize) // using Core Graphic
  newImage = image.resizeIO(size: desiredSize) // using Image I/O
  newImage = image.resizeCI(size: desiredSize) // using Core Image
  newImage = image.resizeVI(size: desiredSize) // using vImage
```

You can find me with #iOSBySheldon in Github, Youtube, Facebook, etc. You are more than welcome to follow me in all the places.

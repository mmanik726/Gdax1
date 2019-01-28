# Gdax1

Gdax1 is a iOS app to trade cryptocurrency on the Gdax (now Coinbase PRO) cryptocurrency trading servers. 

Gdax1 is multi-threaded and handles multiple requests and operations depending on market conditions.

Gdax1 also works in the background and notifies you of significant price changes of a cryto currency asset. 

It uses the REST API provided by coinbase to communicate with the servers. 


## Installation

Use the Cocoapods dependency manager to install the dependencies

Install Cocoapods (if not already installed) 
```bash
sudo gem install cocoapods
```

Cocoapods uses pod files to install the dependencies

installing project dependencies:

cd into your project directory 

```bash
pod install
```

Now launch the Gdax1.xcworkspace using Xcode

you should now be able to do a build of your project in Xcode


## Screenshots

### Trading Ui 
![Alt text](https://github.com/mmanik726/Gdax1/blob/master/Gdax1_screenshot1.png?raw=true "Gdax1 screenshot1")

### Background Notification 
![Alt text](https://github.com/mmanik726/Gdax1/blob/master/Gdax1_screenshot2.png?raw=true "Gdax1 screenshot2")

### Gdax1 Class Diagram 
![Alt text](https://github.com/mmanik726/Gdax1/blob/master/Gdax1_ClassDiagram.jpg?raw=true "Gdax1 Class Diagram")

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)

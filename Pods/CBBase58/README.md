# CBBase58
从 CoreBitcoin 项目摘出来的base58部分代码，可以直接引用Base58 

创建该repo 是因为公司区块链项目需要用到base58，但在pod和github上又没找到合适的库

于是自己创建一个，方便项目集成

其实 CoreBitcoin项目中有其他与区块链相关的更为完整的pod库

但我不需要那么多，万一其他类别的项目也用到了base58，可以简单的集成CBBase58就可以了

### CoreBitcoin项目地址
https://github.com/oleganza/CoreBitcoin

### 使用方法
```
pod 'CBBase58'
```
### base58的查询字母表

我的CBBase58 是从CoreBitcoin摘出来的，CoreBitcoin是比特币的pod库，他的base58 最后查询的字母表与比特币的保持一致，如果有更改的需要，可以从github上下载代码并修改。

修改代码的位置为：
BTCBase58.m  
```
static const char* BTCBase58Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
```

# 关于base58
base58和base64一样是一种二进制转可视字符串的算法，主要用来转换大整数值。区别是，转换出来的字符串，去除了几个看起来会产生歧义的字符，如 0 (零), O (大写字母O), I (大写的字母i) and l (小写的字母L) ，和几个影响双击选择的字符，如/, +。结果字符集正好58个字符(包括9个数字，24个大写字母，25个小写字母)。不同的应用实现中，base58 最后查询的字母表可能不同，所以没有具体的标准。

比特币之所以加入改进版的 Base58 算法，主要为了解决 Base58 导出的字符串没有校验机制，这样，在传播过程中，如果漏写了几个字符，会检测不出来。所以使用了改进版的算法 Base58Check。

下面是几个应用中的字母表:

比特币地址
```
123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz
```
Monero 地址
```
123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz
```
Ripple 地址
```
rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz
```
Flickr 的短URL
```
123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ
```


nodejs版本的ByteBuffer和C++通信的利器！

推荐结合ExBuffer来实现网络协议：https://github.com/play175/ExBuffer

```javascript
var ByteBuffer = require('./ByteBuffer');

/*************************基本操作****************************/

//压包操作
var sbuf = new ByteBuffer();
var buffer = sbuf.string('abc123你好')//变长字符串，前两个字节表示长度
                       .int32(-999).uint32(999).float(-0.5)
                       .int64(9999999).double(-0.000005).short(32767).ushort(65535)
                       .byte(255)
                       .vstring('abcd',5)//定长字符串,不足的字节补0x00
                       .byteArray([65,66,67,68,69],5)//字节数组，不足字节补0x00
                       .pack();//结尾调用打包方法

console.log(buffer);

//解包操作
var rbuf = new ByteBuffer(buffer);
//解包出来是一个数组
var arr = rbuf.string()//变长字符串，前两个字节表示长度
                    .int32().uint32().float()
                    .int64().double().short().ushort()
                    .byte()
                    .vstring(null,5)//定长字符串,不足的字节补0x00
                    .byteArray(null,5)//字节数组，不足字节补0x00
                    .unpack();//结尾调用解包方法

console.log(arr);


/*************************更多操作****************************/

//指定字符编码(默认：utf8):utf8/ascii/
var sbuf = new ByteBuffer().encoding('ascii');

//指定字节序(默认：BigEndian)
var sbuf = new ByteBuffer().littleEndian();

//指定数据在二进制的初始位置 默认是0
var sbuf = new ByteBuffer(buffer,2);

//插入数据到指定位置
var sbuf = new ByteBuffer();
sbuf.int32(9999,0);//把这个int32数据插入到ByteBuffer的第一个位置

//在打包的时候在开始位置插入一个short型表示包长(通信层中的包头)
var buffer = sbuf.packWithHead();

```

install
```javascript
npm install ByteBuffer -g
```

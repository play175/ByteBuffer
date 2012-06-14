nodejs版本的ByteBuffer和C++通信的利器！

```javascript
var ByteBuffer = require('./ByteBuffer');


//压包操作
var sbuf = new ByteBuffer();
var buffer = sbuf.string('abc123你好')//变长字符串，前两个字节表示长度
                       .int32(-999).uint32(999).float(-0.5)
                       .int64(9999999).double(-0.000005).short(32767).ushort(65535)
                       .byte(255)
                       .vstring('abcd',5)//定长字符串,不足的字节补0x00
                       .pack();

console.log(buffer);

//解包操作
var rbuf = new ByteBuffer(buffer);
//解包出来是一个数组
var arr = rbuf.string()//变长字符串，前两个字节表示长度
                    .int32().uint32().float()
                    .int64().double().short().ushort()
                    .byte()
                    .vstring(null,5)//定长字符串,不足的字节补0x00
                    .unpack();

console.log(arr);


//指定字符编码(默认：utf8):utf8/ascii/
//指定字节序(默认：LittleEndian)
var sbuf = new ByteBuffer().encoding('ascii').bigEndian().string('abc123');
var rbuf = new ByteBuffer(sbuf.pack()).encoding('ascii').bigEndian();
console.log(rbuf.string().unpack());


```

install
```javascript
npm install ByteBuffer -g
```
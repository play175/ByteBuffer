var ByteBuffer = require('./ByteBuffer');

//压包操作
var sbuf = new ByteBuffer();
var buffer = sbuf.string('abc123').int32(999).uint32(11).float(0.5)
                       .int64(9999999).double(-0.5).short(3333).ushort(354)
                       .byte(14)
                       .vstring('abcd',10)//定长字符串
                       .pack();

console.log(buffer);

//解包操作
var rbuf = new ByteBuffer(buffer);
//解包出来是一个数组
var arr = rbuf.string().int32().uint32().float()
                    .int64().double().short().ushort()
                    .byte()
                    .vstring(null,10)//定长字符串
                    .unpack();

console.log(arr);

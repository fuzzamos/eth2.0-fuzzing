package fuzz

import (
    "github.com/protolambda/zrnt/eth2/util/shuffling"
    "github.com/protolambda/zrnt/eth2/core"
    "encoding/binary"
)

func Fuzz(data []byte) []byte {
    if len(data) < 32 + 2 {
        return []byte{}
    }

    count := int(binary.LittleEndian.Uint16(data[:2])) % 100
    var seed [32]byte
    copy(seed[:], data[2:34])

    input := make([]core.ValidatorIndex, count)
    for i := 0; i < count; i++ {
        input[i] = core.ValidatorIndex(i)
    }

    shuffling.UnshuffleList(input, seed)

    ret := make([]byte, count * 8)
    for i := 0; i < count; i++ {
        binary.LittleEndian.PutUint64(ret[i * 8:], uint64(input[i]))
    }

    return ret
}

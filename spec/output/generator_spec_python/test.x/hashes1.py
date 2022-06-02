# This is an automatically generated file.
# DO NOT EDIT or your changes may be overwritten
import base64
from typing import List
from xdrlib import Packer, Unpacker

from .hash import Hash

__all__ = ["Hashes1"]


class Hashes1:
    """
    XDR Source Code::

        typedef Hash Hashes1[12];
    """

    def __init__(self, hashes1: List[Hash]) -> None:
        if hashes1 and len(hashes1) != 12:
            expect_size = 12
            raise ValueError(
                f"The length of `hashes1` should be {expect_size}, but got {len(hashes1)}."
            )
        self.hashes1 = hashes1

    def pack(self, packer: Packer) -> None:
        for hashes1_item in self.hashes1:
            hashes1_item.pack(packer)

    @classmethod
    def unpack(cls, unpacker: Unpacker) -> "Hashes1":
        length = 12
        hashes1 = []
        for _ in range(length):
            hashes1.append(Hash.unpack(unpacker))
        return cls(hashes1)

    def to_xdr_bytes(self) -> bytes:
        packer = Packer()
        self.pack(packer)
        return packer.get_buffer()

    @classmethod
    def from_xdr_bytes(cls, xdr: bytes) -> "Hashes1":
        unpacker = Unpacker(xdr)
        return cls.unpack(unpacker)

    def to_xdr(self) -> str:
        xdr_bytes = self.to_xdr_bytes()
        return base64.b64encode(xdr_bytes).decode()

    @classmethod
    def from_xdr(cls, xdr: str) -> "Hashes1":
        xdr_bytes = base64.b64decode(xdr.encode())
        return cls.from_xdr_bytes(xdr_bytes)

    def __eq__(self, other: object):
        if not isinstance(other, self.__class__):
            return NotImplemented
        return self.hashes1 == other.hashes1

    def __str__(self):
        return f"<Hashes1 [hashes1={self.hashes1}]>"

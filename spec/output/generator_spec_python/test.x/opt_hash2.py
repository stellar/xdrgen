# This is an automatically generated file.
# DO NOT EDIT or your changes may be overwritten
import base64
from typing import Optional
from xdrlib import Packer, Unpacker

from .hash import Hash

__all__ = ["OptHash2"]


class OptHash2:
    """
    XDR Source Code::

        typedef Hash* optHash2;
    """

    def __init__(self, opt_hash2: Optional[Hash]) -> None:
        self.opt_hash2 = opt_hash2

    def pack(self, packer: Packer) -> None:
        if self.opt_hash2 is None:
            packer.pack_uint(0)
        else:
            packer.pack_uint(1)
            if self.opt_hash2 is None:
                raise ValueError("opt_hash2 should not be None.")
            self.opt_hash2.pack(packer)

    @classmethod
    def unpack(cls, unpacker: Unpacker) -> "OptHash2":
        opt_hash2 = Hash.unpack(unpacker) if unpacker.unpack_uint() else None
        return cls(opt_hash2)

    def to_xdr_bytes(self) -> bytes:
        packer = Packer()
        self.pack(packer)
        return packer.get_buffer()

    @classmethod
    def from_xdr_bytes(cls, xdr: bytes) -> "OptHash2":
        unpacker = Unpacker(xdr)
        return cls.unpack(unpacker)

    def to_xdr(self) -> str:
        xdr_bytes = self.to_xdr_bytes()
        return base64.b64encode(xdr_bytes).decode()

    @classmethod
    def from_xdr(cls, xdr: str) -> "OptHash2":
        xdr_bytes = base64.b64decode(xdr.encode())
        return cls.from_xdr_bytes(xdr_bytes)

    def __eq__(self, other: object):
        if not isinstance(other, self.__class__):
            return NotImplemented
        return self.opt_hash2 == other.opt_hash2

    def __str__(self):
        return f"<OptHash2 [opt_hash2={self.opt_hash2}]>"

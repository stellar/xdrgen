use byteorder::{BigEndian, ReadBytesExt, WriteBytesExt};
use std::{
    fmt::Debug,
    io,
    io::{Cursor, Read, Write},
    num::TryFromIntError,
};

#[derive(Debug)]
pub enum Error {
    Invalid,
    IO(io::Error),
    OutOfRange(TryFromIntError),
}

impl From<io::Error> for Error {
    fn from(e: io::Error) -> Self {
        Error::IO(e)
    }
}

impl From<TryFromIntError> for Error {
    fn from(e: TryFromIntError) -> Self {
        Error::OutOfRange(e)
    }
}

pub type Result<T> = std::result::Result<T, Error>;

pub trait ReadXDR
where
    Self: Sized,
{
    fn read_xdr(r: &mut impl Read) -> Result<Self>;

    fn read_xdr_into(&mut self, r: &mut impl Read) -> Result<()> {
        *self = Self::read_xdr(r)?;
        Ok(())
    }

    fn from_xdr_base64(b64: String) -> Result<Self> {
        let mut b64_reader = Cursor::new(b64);
        let mut dec = base64::read::DecoderReader::new(&mut b64_reader, base64::STANDARD);
        let t = Self::read_xdr(&mut dec)?;
        Ok(t)
    }
}

pub trait WriteXDR {
    fn write_xdr(&self, w: &mut impl Write) -> Result<()>;

    fn to_xdr_base64(&self) -> Result<String> {
        let mut enc = base64::write::EncoderStringWriter::new(base64::STANDARD);
        self.write_xdr(&mut enc)?;
        let b64 = enc.into_inner();
        Ok(b64)
    }
}

impl ReadXDR for i32 {
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = r.read_i32::<BigEndian>()?;
        Ok(i)
    }
}

impl WriteXDR for i32 {
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        w.write_i32::<BigEndian>(*self).map_err(Error::IO)?;
        Ok(())
    }
}

impl ReadXDR for u32 {
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = r.read_u32::<BigEndian>()?;
        Ok(i)
    }
}

impl WriteXDR for u32 {
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        w.write_u32::<BigEndian>(*self)?;
        Ok(())
    }
}

impl ReadXDR for i64 {
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = r.read_i64::<BigEndian>()?;
        Ok(i)
    }
}

impl WriteXDR for i64 {
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        w.write_i64::<BigEndian>(*self)?;
        Ok(())
    }
}

impl ReadXDR for u64 {
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = r.read_u64::<BigEndian>()?;
        Ok(i)
    }
}

impl WriteXDR for u64 {
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        w.write_u64::<BigEndian>(*self)?;
        Ok(())
    }
}

impl ReadXDR for f32 {
    fn read_xdr(_r: &mut impl Read) -> Result<Self> {
        todo!()
    }
}

impl WriteXDR for f32 {
    fn write_xdr(&self, _w: &mut impl Write) -> Result<()> {
        todo!()
    }
}

impl ReadXDR for f64 {
    fn read_xdr(_r: &mut impl Read) -> Result<Self> {
        todo!()
    }
}

impl WriteXDR for f64 {
    fn write_xdr(&self, _w: &mut impl Write) -> Result<()> {
        todo!()
    }
}

impl ReadXDR for bool {
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = r.read_u32::<BigEndian>()?;
        let b = i == 1;
        Ok(b)
    }
}

impl WriteXDR for bool {
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        let i = if *self { 1 } else { 0 };
        w.write_u32::<BigEndian>(i)?;
        Ok(())
    }
}

impl<T: ReadXDR> ReadXDR for Option<T> {
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i: u32 = r.read_u32::<BigEndian>()?;
        match i {
            0 => Ok(None),
            1 => {
                let t = T::read_xdr(r)?;
                Ok(Some(t))
            }
            _ => Err(Error::Invalid),
        }
    }
}

impl<T: WriteXDR> WriteXDR for Option<T> {
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        if let Some(t) = self {
            w.write_u32::<BigEndian>(1)?;
            t.write_xdr(w)?;
        } else {
            w.write_u32::<BigEndian>(0)?;
        }
        Ok(())
    }
}

impl<T: ReadXDR> ReadXDR for Box<T> {
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let t = T::read_xdr(r)?;
        Ok(Box::new(t))
    }
}

impl<T: WriteXDR> WriteXDR for Box<T> {
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        T::write_xdr(self, w)?;
        Ok(())
    }
}

impl ReadXDR for () {
    fn read_xdr(_r: &mut impl Read) -> Result<Self> {
        Ok(())
    }
}

impl WriteXDR for () {
    fn write_xdr(&self, _w: &mut impl Write) -> Result<()> {
        Ok(())
    }
}

impl ReadXDR for Vec<u8> {
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let len: u32 = u32::read_xdr(r)?;
        // TODO: Error on length greater than max length.

        let mut vec = vec![0u8; len as usize];
        r.read_exact(&mut vec)?;

        let pad_len = (4 - (len % 4)) % 4;
        let mut pad = vec![0u8; pad_len as usize];
        r.read_exact(&mut pad)?;

        Ok(vec)
    }
}

impl WriteXDR for Vec<u8> {
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        let len: u32 = self.len().try_into()?;
        // TODO: Error on length greater than max length.
        w.write_u32::<BigEndian>(len)?;

        w.write_all(self)?;

        let pad_len = (4 - (len % 4)) % 4;
        let mut pad = vec![0u8; pad_len as usize];
        w.write_all(&mut pad)?;

        Ok(())
    }
}

impl<T: ReadXDR> ReadXDR for Vec<T> {
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let len = u32::read_xdr(r)?;
        // TODO: Error on length greater than max length.

        let mut vec = Vec::with_capacity(len.try_into()?);
        for _ in 0..len {
            let t = T::read_xdr(r)?;
            vec.push(t);
        }

        Ok(vec)
    }
}

impl<T: WriteXDR> WriteXDR for Vec<T> {
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        let len: u32 = self.len().try_into()?;
        // TODO: Error on length greater than max length.
        w.write_u32::<BigEndian>(len)?;

        for t in self.iter() {
            t.write_xdr(w)?;
        }

        Ok(())
    }
}

impl<const N: usize> ReadXDR for [u8; N] {
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let mut arr = [0u8; N];
        r.read_exact(&mut arr)?;
        Ok(arr)
    }
}

impl<const N: usize> WriteXDR for [u8; N] {
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        w.write_all(self)?;
        Ok(())
    }
}

impl<T: ReadXDR + Clone, const N: usize> ReadXDR for [T; N] {
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let mut vec = Vec::with_capacity(N);
        for _ in 0..N {
            let t = T::read_xdr(r)?;
            vec.push(t);
        }
        let arr: [T; N] = vec.try_into().unwrap_or_else(|_: Vec<T>| unreachable!());
        Ok(arr)
    }
}

impl<T: WriteXDR + Clone, const N: usize> WriteXDR for [T; N] {
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        for t in self {
            t.write_xdr(w)?;
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    // TODO: Write tests.
}

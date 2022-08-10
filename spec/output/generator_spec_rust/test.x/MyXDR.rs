// Module  is generated from:
//  spec/fixtures/generator/test.x

#![allow(clippy::missing_errors_doc, clippy::unreadable_literal)]

/// `XDR_FILES_SHA256` is a list of pairs of source files and their SHA256 hashes.
pub const XDR_FILES_SHA256: [(&str, &str); 1] = [
  ("spec/fixtures/generator/test.x", "d29a98a6a3b9bf533a3e6712d928e0bed655e0f462ac4dae810c65d52ca9af41")
];

use core::{array::TryFromSliceError, fmt, fmt::Debug, marker::Sized, ops::Deref, slice};

#[cfg(feature = "std")]
use core::marker::PhantomData;

// When feature alloc is turned off use static lifetime Box and Vec types.
#[cfg(not(feature = "alloc"))]
mod noalloc {
    pub mod boxed {
        pub type Box<T> = &'static T;
    }
    pub mod vec {
        pub type Vec<T> = &'static [T];
    }
}
#[cfg(not(feature = "alloc"))]
use noalloc::{boxed::Box, vec::Vec};

// When feature std is turned off, but feature alloc is turned on import the
// alloc crate and use its Box and Vec types.
#[cfg(all(not(feature = "std"), feature = "alloc"))]
extern crate alloc;
#[cfg(all(not(feature = "std"), feature = "alloc"))]
use alloc::{
    borrow::ToOwned,
    boxed::Box,
    string::{FromUtf8Error, String},
    vec::Vec,
};
#[cfg(all(feature = "std"))]
use std::string::FromUtf8Error;

#[cfg(feature = "arbitrary")]
use arbitrary::Arbitrary;

// TODO: Add support for read/write xdr fns when std not available.

#[cfg(feature = "std")]
use std::{
    error, io,
    io::{BufRead, BufReader, Cursor, Read, Write},
};

/// Error contains all errors returned by functions in this crate. It can be
/// compared via `PartialEq`, however any contained IO errors will only be
/// compared on their `ErrorKind`.
#[derive(Debug)]
pub enum Error {
    Invalid,
    LengthExceedsMax,
    LengthMismatch,
    NonZeroPadding,
    Utf8Error(core::str::Utf8Error),
    #[cfg(feature = "std")]
    Io(io::Error),
}

impl PartialEq for Error {
    fn eq(&self, other: &Self) -> bool {
        match (self, other) {
            (Self::Utf8Error(l), Self::Utf8Error(r)) => l == r,
            // IO errors cannot be compared, but in the absence of any more
            // meaningful way to compare the errors we compare the kind of error
            // and ignore the embedded source error or OS error. The main use
            // case for comparing errors outputted by the XDR library is for
            // error case testing, and a lack of the ability to compare has a
            // detrimental affect on failure testing, so this is a tradeoff.
            #[cfg(feature = "std")]
            (Self::Io(l), Self::Io(r)) => l.kind() == r.kind(),
            _ => core::mem::discriminant(self) == core::mem::discriminant(other),
        }
    }
}

#[cfg(feature = "std")]
impl error::Error for Error {
    #[must_use]
    fn source(&self) -> Option<&(dyn error::Error + 'static)> {
        match self {
            Self::Io(e) => Some(e),
            _ => None,
        }
    }
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Error::Invalid => write!(f, "xdr value invalid"),
            Error::LengthExceedsMax => write!(f, "xdr value max length exceeded"),
            Error::LengthMismatch => write!(f, "xdr value length does not match"),
            Error::NonZeroPadding => write!(f, "xdr padding contains non-zero bytes"),
            Error::Utf8Error(e) => write!(f, "{}", e),
            #[cfg(feature = "std")]
            Error::Io(e) => write!(f, "{}", e),
        }
    }
}

impl From<TryFromSliceError> for Error {
    fn from(_: TryFromSliceError) -> Error {
        Error::LengthMismatch
    }
}

impl From<core::str::Utf8Error> for Error {
    #[must_use]
    fn from(e: core::str::Utf8Error) -> Self {
        Error::Utf8Error(e)
    }
}

#[cfg(feature = "alloc")]
impl From<FromUtf8Error> for Error {
    #[must_use]
    fn from(e: FromUtf8Error) -> Self {
        Error::Utf8Error(e.utf8_error())
    }
}

#[cfg(feature = "std")]
impl From<io::Error> for Error {
    #[must_use]
    fn from(e: io::Error) -> Self {
        Error::Io(e)
    }
}

impl From<Error> for () {
    fn from(_: Error) {}
}

#[allow(dead_code)]
type Result<T> = core::result::Result<T, Error>;

/// Name defines types that assign a static name to their value, such as the
/// name given to an identifier in an XDR enum, or the name given to the case in
/// a union.
pub trait Name {
    fn name(&self) -> &'static str;
}

/// Discriminant defines types that may contain a one-of value determined
/// according to the discriminant, and exposes the value of the discriminant for
/// that type, such as in an XDR union.
pub trait Discriminant<D> {
    fn discriminant(&self) -> D;
}

/// Iter defines types that have variants that can be iterated.
pub trait Variants<V> {
    fn variants() -> slice::Iter<'static, V>
    where
        V: Sized;
}

// Enum defines a type that is represented as an XDR enumeration when encoded.
pub trait Enum: Name + Variants<Self> + Sized {}

// Union defines a type that is represented as an XDR union when encoded.
pub trait Union<D>: Name + Discriminant<D> + Variants<D>
where
    D: Sized,
{
}

#[cfg(feature = "std")]
pub struct ReadXdrIter<'r, R: Read, S: ReadXdr> {
    reader: BufReader<&'r mut R>,
    _s: PhantomData<S>,
}

#[cfg(feature = "std")]
impl<'r, R: Read, S: ReadXdr> ReadXdrIter<'r, R, S> {
    fn new(r: &'r mut R) -> Self {
        Self {
            reader: BufReader::new(r),
            _s: PhantomData,
        }
    }
}

#[cfg(feature = "std")]
impl<'r, R: Read, S: ReadXdr> Iterator for ReadXdrIter<'r, R, S> {
    type Item = Result<S>;

    // Next reads the internal reader and XDR decodes it into the Self type. If
    // the EOF is reached without reading any new bytes `None` is returned. If
    // EOF is reached after reading some bytes a truncated entry is assumed an
    // an `Error::Io` containing an `UnexpectedEof`. If any other IO error
    // occurs it is returned. Iteration of this iterator stops naturally when
    // `None` is returned, but not when a `Some(Err(...))` is returned. The
    // caller is responsible for checking each Result.
    fn next(&mut self) -> Option<Self::Item> {
        // Try to fill the buffer to see if the EOF has been reached or not.
        // This happens to effectively peek to see if the stream has finished
        // and there are no more items.  It is necessary to do this because the
        // xdr types in this crate heavily use the `std::io::Read::read_exact`
        // method that doesn't distinguish between an EOF at the beginning of a
        // read and an EOF after a partial fill of a read_exact.
        match self.reader.fill_buf() {
            // If the reader has no more data and is unable to fill any new data
            // into its internal buf, then the EOF has been reached.
            Ok([]) => return None,
            // If an error occurs filling the buffer, treat that as an error and stop.
            Err(e) => return Some(Err(Error::Io(e))),
            // If there is data in the buf available for reading, continue.
            Ok([..]) => (),
        };
        // Read the buf into the type.
        match S::read_xdr(&mut self.reader) {
            Ok(s) => Some(Ok(s)),
            Err(e) => Some(Err(e)),
        }
    }
}

pub trait ReadXdr
where
    Self: Sized,
{
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self>;

    #[cfg(feature = "std")]
    fn read_xdr_into(&mut self, r: &mut impl Read) -> Result<()> {
        *self = Self::read_xdr(r)?;
        Ok(())
    }

    #[cfg(feature = "std")]
    fn read_xdr_iter<R: Read>(r: &mut R) -> ReadXdrIter<R, Self> {
        ReadXdrIter::new(r)
    }

    #[cfg(feature = "std")]
    fn from_xdr<B: AsRef<[u8]>>(bytes: B) -> Result<Self> {
        let mut cursor = Cursor::new(bytes.as_ref());
        let t = Self::read_xdr(&mut cursor)?;
        Ok(t)
    }

    #[cfg(feature = "base64")]
    fn from_xdr_base64(b64: String) -> Result<Self> {
        let mut b64_reader = Cursor::new(b64);
        let mut dec = base64::read::DecoderReader::new(&mut b64_reader, base64::STANDARD);
        let t = Self::read_xdr(&mut dec)?;
        Ok(t)
    }
}

pub trait WriteXdr {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()>;

    #[cfg(feature = "std")]
    fn to_xdr(&self) -> Result<Vec<u8>> {
        let mut cursor = Cursor::new(vec![]);
        self.write_xdr(&mut cursor)?;
        let bytes = cursor.into_inner();
        Ok(bytes)
    }

    #[cfg(feature = "base64")]
    fn to_xdr_base64(&self) -> Result<String> {
        let mut enc = base64::write::EncoderStringWriter::new(base64::STANDARD);
        self.write_xdr(&mut enc)?;
        let b64 = enc.into_inner();
        Ok(b64)
    }
}

/// `Pad_len` returns the number of bytes to pad an XDR value of the given
/// length to make the final serialized size a multiple of 4.
#[cfg(feature = "std")]
fn pad_len(len: usize) -> usize {
    (4 - (len % 4)) % 4
}

impl ReadXdr for i32 {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let mut b = [0u8; 4];
        r.read_exact(&mut b)?;
        let i = i32::from_be_bytes(b);
        Ok(i)
    }
}

impl WriteXdr for i32 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        let b: [u8; 4] = self.to_be_bytes();
        w.write_all(&b)?;
        Ok(())
    }
}

impl ReadXdr for u32 {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let mut b = [0u8; 4];
        r.read_exact(&mut b)?;
        let i = u32::from_be_bytes(b);
        Ok(i)
    }
}

impl WriteXdr for u32 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        let b: [u8; 4] = self.to_be_bytes();
        w.write_all(&b)?;
        Ok(())
    }
}

impl ReadXdr for i64 {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let mut b = [0u8; 8];
        r.read_exact(&mut b)?;
        let i = i64::from_be_bytes(b);
        Ok(i)
    }
}

impl WriteXdr for i64 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        let b: [u8; 8] = self.to_be_bytes();
        w.write_all(&b)?;
        Ok(())
    }
}

impl ReadXdr for u64 {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let mut b = [0u8; 8];
        r.read_exact(&mut b)?;
        let i = u64::from_be_bytes(b);
        Ok(i)
    }
}

impl WriteXdr for u64 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        let b: [u8; 8] = self.to_be_bytes();
        w.write_all(&b)?;
        Ok(())
    }
}

impl ReadXdr for f32 {
    #[cfg(feature = "std")]
    fn read_xdr(_r: &mut impl Read) -> Result<Self> {
        todo!()
    }
}

impl WriteXdr for f32 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, _w: &mut impl Write) -> Result<()> {
        todo!()
    }
}

impl ReadXdr for f64 {
    #[cfg(feature = "std")]
    fn read_xdr(_r: &mut impl Read) -> Result<Self> {
        todo!()
    }
}

impl WriteXdr for f64 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, _w: &mut impl Write) -> Result<()> {
        todo!()
    }
}

impl ReadXdr for bool {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = u32::read_xdr(r)?;
        let b = i == 1;
        Ok(b)
    }
}

impl WriteXdr for bool {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        let i: u32 = if *self { 1 } else { 0 };
        i.write_xdr(w)?;
        Ok(())
    }
}

impl<T: ReadXdr> ReadXdr for Option<T> {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = u32::read_xdr(r)?;
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

impl<T: WriteXdr> WriteXdr for Option<T> {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        if let Some(t) = self {
            1u32.write_xdr(w)?;
            t.write_xdr(w)?;
        } else {
            0u32.write_xdr(w)?;
        }
        Ok(())
    }
}

impl<T: ReadXdr> ReadXdr for Box<T> {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let t = T::read_xdr(r)?;
        Ok(Box::new(t))
    }
}

impl<T: WriteXdr> WriteXdr for Box<T> {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        T::write_xdr(self, w)?;
        Ok(())
    }
}

impl ReadXdr for () {
    #[cfg(feature = "std")]
    fn read_xdr(_r: &mut impl Read) -> Result<Self> {
        Ok(())
    }
}

impl WriteXdr for () {
    #[cfg(feature = "std")]
    fn write_xdr(&self, _w: &mut impl Write) -> Result<()> {
        Ok(())
    }
}

impl<const N: usize> ReadXdr for [u8; N] {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let mut arr = [0u8; N];
        r.read_exact(&mut arr)?;

        let pad = &mut [0u8; 3][..pad_len(N)];
        r.read_exact(pad)?;
        if pad.iter().any(|b| *b != 0) {
            return Err(Error::NonZeroPadding);
        }

        Ok(arr)
    }
}

impl<const N: usize> WriteXdr for [u8; N] {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        w.write_all(self)?;
        w.write_all(&[0u8; 3][..pad_len(N)])?;
        Ok(())
    }
}

impl<T: ReadXdr, const N: usize> ReadXdr for [T; N] {
    #[cfg(feature = "std")]
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

impl<T: WriteXdr, const N: usize> WriteXdr for [T; N] {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        for t in self {
            t.write_xdr(w)?;
        }
        Ok(())
    }
}

#[cfg(feature = "alloc")]
#[derive(Debug, Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
pub struct VecM<T, const MAX: u32 = { u32::MAX }>(Vec<T>);

#[cfg(not(feature = "alloc"))]
#[derive(Debug, Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
pub struct VecM<T, const MAX: u32 = { u32::MAX }>(Vec<T>)
where
    T: 'static;

impl<T, const MAX: u32> Deref for VecM<T, MAX> {
    type Target = Vec<T>;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl<T, const MAX: u32> Default for VecM<T, MAX> {
    fn default() -> Self {
        Self(Vec::default())
    }
}

impl<T, const MAX: u32> VecM<T, MAX> {
    pub const MAX_LEN: usize = { MAX as usize };

    #[must_use]
    #[allow(clippy::unused_self)]
    pub fn max_len(&self) -> usize {
        Self::MAX_LEN
    }

    #[must_use]
    pub fn as_vec(&self) -> &Vec<T> {
        self.as_ref()
    }
}

impl<T: Clone, const MAX: u32> VecM<T, MAX> {
    #[must_use]
    #[cfg(feature = "alloc")]
    pub fn to_vec(&self) -> Vec<T> {
        self.into()
    }

    #[must_use]
    pub fn into_vec(self) -> Vec<T> {
        self.into()
    }
}

impl<const MAX: u32> VecM<u8, MAX> {
    #[cfg(feature = "alloc")]
    pub fn to_string(&self) -> Result<String> {
        self.try_into()
    }

    #[cfg(feature = "alloc")]
    pub fn into_string(self) -> Result<String> {
        self.try_into()
    }
}

impl<T, const MAX: u32> TryFrom<Vec<T>> for VecM<T, MAX> {
    type Error = Error;

    fn try_from(v: Vec<T>) -> Result<Self> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(VecM(v))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

impl<T, const MAX: u32> From<VecM<T, MAX>> for Vec<T> {
    #[must_use]
    fn from(v: VecM<T, MAX>) -> Self {
        v.0
    }
}

#[cfg(feature = "alloc")]
impl<T: Clone, const MAX: u32> From<&VecM<T, MAX>> for Vec<T> {
    #[must_use]
    fn from(v: &VecM<T, MAX>) -> Self {
        v.0.clone()
    }
}

impl<T, const MAX: u32> AsRef<Vec<T>> for VecM<T, MAX> {
    #[must_use]
    fn as_ref(&self) -> &Vec<T> {
        &self.0
    }
}

#[cfg(feature = "alloc")]
impl<T: Clone, const MAX: u32> TryFrom<&Vec<T>> for VecM<T, MAX> {
    type Error = Error;

    fn try_from(v: &Vec<T>) -> Result<Self> {
        v.as_slice().try_into()
    }
}

#[cfg(feature = "alloc")]
impl<T: Clone, const MAX: u32> TryFrom<&[T]> for VecM<T, MAX> {
    type Error = Error;

    fn try_from(v: &[T]) -> Result<Self> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(VecM(v.to_vec()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

impl<T, const MAX: u32> AsRef<[T]> for VecM<T, MAX> {
    #[cfg(feature = "alloc")]
    #[must_use]
    fn as_ref(&self) -> &[T] {
        self.0.as_ref()
    }
    #[cfg(not(feature = "alloc"))]
    #[must_use]
    fn as_ref(&self) -> &[T] {
        self.0
    }
}

#[cfg(feature = "alloc")]
impl<T: Clone, const N: usize, const MAX: u32> TryFrom<[T; N]> for VecM<T, MAX> {
    type Error = Error;

    fn try_from(v: [T; N]) -> Result<Self> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(VecM(v.to_vec()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(feature = "alloc")]
impl<T: Clone, const N: usize, const MAX: u32> TryFrom<VecM<T, MAX>> for [T; N] {
    type Error = VecM<T, MAX>;

    fn try_from(v: VecM<T, MAX>) -> core::result::Result<Self, Self::Error> {
        let s: [T; N] = v.0.try_into().map_err(|v: Vec<T>| VecM::<T, MAX>(v))?;
        Ok(s)
    }
}

#[cfg(feature = "alloc")]
impl<T: Clone, const N: usize, const MAX: u32> TryFrom<&[T; N]> for VecM<T, MAX> {
    type Error = Error;

    fn try_from(v: &[T; N]) -> Result<Self> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(VecM(v.to_vec()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(not(feature = "alloc"))]
impl<T: Clone, const N: usize, const MAX: u32> TryFrom<&'static [T; N]> for VecM<T, MAX> {
    type Error = Error;

    fn try_from(v: &'static [T; N]) -> Result<Self> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(VecM(v))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&String> for VecM<u8, MAX> {
    type Error = Error;

    fn try_from(v: &String) -> Result<Self> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(VecM(v.as_bytes().to_vec()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<String> for VecM<u8, MAX> {
    type Error = Error;

    fn try_from(v: String) -> Result<Self> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(VecM(v.into()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<VecM<u8, MAX>> for String {
    type Error = Error;

    fn try_from(v: VecM<u8, MAX>) -> Result<Self> {
        Ok(String::from_utf8(v.0)?)
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&VecM<u8, MAX>> for String {
    type Error = Error;

    fn try_from(v: &VecM<u8, MAX>) -> Result<Self> {
        Ok(core::str::from_utf8(v.as_ref())?.to_owned())
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&str> for VecM<u8, MAX> {
    type Error = Error;

    fn try_from(v: &str) -> Result<Self> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(VecM(v.into()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(not(feature = "alloc"))]
impl<const MAX: u32> TryFrom<&'static str> for VecM<u8, MAX> {
    type Error = Error;

    fn try_from(v: &'static str) -> Result<Self> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(VecM(v.as_bytes()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

impl<'a, const MAX: u32> TryFrom<&'a VecM<u8, MAX>> for &'a str {
    type Error = Error;

    fn try_from(v: &'a VecM<u8, MAX>) -> Result<Self> {
        Ok(core::str::from_utf8(v.as_ref())?)
    }
}

impl<const MAX: u32> ReadXdr for VecM<u8, MAX> {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let len: u32 = u32::read_xdr(r)?;
        if len > MAX {
            return Err(Error::LengthExceedsMax);
        }

        let mut vec = vec![0u8; len as usize];
        r.read_exact(&mut vec)?;

        let pad = &mut [0u8; 3][..pad_len(len as usize)];
        r.read_exact(pad)?;
        if pad.iter().any(|b| *b != 0) {
            return Err(Error::NonZeroPadding);
        }

        Ok(VecM(vec))
    }
}

impl<const MAX: u32> WriteXdr for VecM<u8, MAX> {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        let len: u32 = self.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        len.write_xdr(w)?;

        w.write_all(&self.0)?;

        w.write_all(&[0u8; 3][..pad_len(len as usize)])?;

        Ok(())
    }
}

impl<T: ReadXdr, const MAX: u32> ReadXdr for VecM<T, MAX> {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let len = u32::read_xdr(r)?;
        if len > MAX {
            return Err(Error::LengthExceedsMax);
        }

        let mut vec = Vec::with_capacity(len as usize);
        for _ in 0..len {
            let t = T::read_xdr(r)?;
            vec.push(t);
        }

        Ok(VecM(vec))
    }
}

impl<T: WriteXdr, const MAX: u32> WriteXdr for VecM<T, MAX> {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        let len: u32 = self.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        len.write_xdr(w)?;

        for t in &self.0 {
            t.write_xdr(w)?;
        }

        Ok(())
    }
}

#[cfg(all(test, feature = "std"))]
mod tests {
    use std::io::Cursor;

    use crate::WriteXdr;

    use super::{Error, ReadXdr, VecM};

    #[test]
    pub fn vec_u8_read_without_padding() {
        let mut buf = Cursor::new(vec![0, 0, 0, 4, 2, 2, 2, 2]);
        let v = VecM::<u8, 8>::read_xdr(&mut buf).unwrap();
        assert_eq!(v.to_vec(), vec![2, 2, 2, 2]);
    }

    #[test]
    pub fn vec_u8_read_with_padding() {
        let mut buf = Cursor::new(vec![0, 0, 0, 1, 2, 0, 0, 0]);
        let v = VecM::<u8, 8>::read_xdr(&mut buf).unwrap();
        assert_eq!(v.to_vec(), vec![2]);
    }

    #[test]
    pub fn vec_u8_read_with_insufficient_padding() {
        let mut buf = Cursor::new(vec![0, 0, 0, 1, 2, 0, 0]);
        let res = VecM::<u8, 8>::read_xdr(&mut buf);
        match res {
            Err(Error::Io(_)) => (),
            _ => panic!("expected IO error got {:?}", res),
        }
    }

    #[test]
    pub fn vec_u8_read_with_non_zero_padding() {
        let mut buf = Cursor::new(vec![0, 0, 0, 1, 2, 3, 0, 0]);
        let res = VecM::<u8, 8>::read_xdr(&mut buf);
        match res {
            Err(Error::NonZeroPadding) => (),
            _ => panic!("expected NonZeroPadding got {:?}", res),
        }
    }

    #[test]
    pub fn vec_u8_write_without_padding() {
        let mut buf = vec![];
        let v: VecM<u8, 8> = vec![2, 2, 2, 2].try_into().unwrap();
        v.write_xdr(&mut Cursor::new(&mut buf)).unwrap();
        assert_eq!(buf, vec![0, 0, 0, 4, 2, 2, 2, 2]);
    }

    #[test]
    pub fn vec_u8_write_with_padding() {
        let mut buf = vec![];
        let v: VecM<u8, 8> = vec![2].try_into().unwrap();
        v.write_xdr(&mut Cursor::new(&mut buf)).unwrap();
        assert_eq!(buf, vec![0, 0, 0, 1, 2, 0, 0, 0]);
    }

    #[test]
    pub fn arr_u8_read_without_padding() {
        let mut buf = Cursor::new(vec![2, 2, 2, 2]);
        let v = <[u8; 4]>::read_xdr(&mut buf).unwrap();
        assert_eq!(v, [2, 2, 2, 2]);
    }

    #[test]
    pub fn arr_u8_read_with_padding() {
        let mut buf = Cursor::new(vec![2, 0, 0, 0]);
        let v = <[u8; 1]>::read_xdr(&mut buf).unwrap();
        assert_eq!(v, [2]);
    }

    #[test]
    pub fn arr_u8_read_with_insufficient_padding() {
        let mut buf = Cursor::new(vec![2, 0, 0]);
        let res = <[u8; 1]>::read_xdr(&mut buf);
        match res {
            Err(Error::Io(_)) => (),
            _ => panic!("expected IO error got {:?}", res),
        }
    }

    #[test]
    pub fn arr_u8_read_with_non_zero_padding() {
        let mut buf = Cursor::new(vec![2, 3, 0, 0]);
        let res = <[u8; 1]>::read_xdr(&mut buf);
        match res {
            Err(Error::NonZeroPadding) => (),
            _ => panic!("expected NonZeroPadding got {:?}", res),
        }
    }

    #[test]
    pub fn arr_u8_write_without_padding() {
        let mut buf = vec![];
        [2u8, 2, 2, 2]
            .write_xdr(&mut Cursor::new(&mut buf))
            .unwrap();
        assert_eq!(buf, vec![2, 2, 2, 2]);
    }

    #[test]
    pub fn arr_u8_write_with_padding() {
        let mut buf = vec![];
        [2u8].write_xdr(&mut Cursor::new(&mut buf)).unwrap();
        assert_eq!(buf, vec![2, 0, 0, 0]);
    }
}

// Uint512 is an XDR Typedef defines as:
//
//   typedef opaque uint512[64];
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct Uint512(pub [u8; 64]);

impl From<Uint512> for [u8; 64] {
    #[must_use]
    fn from(x: Uint512) -> Self {
        x.0
    }
}

impl From<[u8; 64]> for Uint512 {
    #[must_use]
    fn from(x: [u8; 64]) -> Self {
        Uint512(x)
    }
}

impl AsRef<[u8; 64]> for Uint512 {
    #[must_use]
    fn as_ref(&self) -> &[u8; 64] {
        &self.0
    }
}

impl ReadXdr for Uint512 {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = <[u8; 64]>::read_xdr(r)?;
        let v = Uint512(i);
        Ok(v)
    }
}

impl WriteXdr for Uint512 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        self.0.write_xdr(w)
    }
}

impl Uint512 {
    #[must_use]
    pub fn as_slice(&self) -> &[u8] {
        &self.0
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<Vec<u8>> for Uint512 {
    type Error = Error;
    fn try_from(x: Vec<u8>) -> Result<Self> {
        x.as_slice().try_into()
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<u8>> for Uint512 {
    type Error = Error;
    fn try_from(x: &Vec<u8>) -> Result<Self> {
        x.as_slice().try_into()
    }
}

impl TryFrom<&[u8]> for Uint512 {
    type Error = Error;
    fn try_from(x: &[u8]) -> Result<Self> {
        Ok(Uint512(x.try_into()?))
    }
}

impl AsRef<[u8]> for Uint512 {
    #[must_use]
    fn as_ref(&self) -> &[u8] {
        &self.0
    }
}

// Uint513 is an XDR Typedef defines as:
//
//   typedef opaque uint513<64>;
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[derive(Default)]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct Uint513(pub VecM::<u8, 64>);

impl From<Uint513> for VecM::<u8, 64> {
    #[must_use]
    fn from(x: Uint513) -> Self {
        x.0
    }
}

impl From<VecM::<u8, 64>> for Uint513 {
    #[must_use]
    fn from(x: VecM::<u8, 64>) -> Self {
        Uint513(x)
    }
}

impl AsRef<VecM::<u8, 64>> for Uint513 {
    #[must_use]
    fn as_ref(&self) -> &VecM::<u8, 64> {
        &self.0
    }
}

impl ReadXdr for Uint513 {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = VecM::<u8, 64>::read_xdr(r)?;
        let v = Uint513(i);
        Ok(v)
    }
}

impl WriteXdr for Uint513 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        self.0.write_xdr(w)
    }
}

impl Deref for Uint513 {
  type Target = VecM::<u8, 64>;
  fn deref(&self) -> &Self::Target {
      &self.0
  }
}

impl From<Uint513> for Vec<u8> {
    #[must_use]
    fn from(x: Uint513) -> Self {
        x.0.0
    }
}

impl TryFrom<Vec<u8>> for Uint513 {
    type Error = Error;
    fn try_from(x: Vec<u8>) -> Result<Self> {
        Ok(Uint513(x.try_into()?))
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<u8>> for Uint513 {
    type Error = Error;
    fn try_from(x: &Vec<u8>) -> Result<Self> {
        Ok(Uint513(x.try_into()?))
    }
}

impl AsRef<Vec<u8>> for Uint513 {
    #[must_use]
    fn as_ref(&self) -> &Vec<u8> {
        &self.0.0
    }
}

impl AsRef<[u8]> for Uint513 {
    #[cfg(feature = "alloc")]
    #[must_use]
    fn as_ref(&self) -> &[u8] {
        &self.0.0
    }
    #[cfg(not(feature = "alloc"))]
    #[must_use]
    fn as_ref(&self) -> &[u8] {
        self.0.0
    }
}

// Uint514 is an XDR Typedef defines as:
//
//   typedef opaque uint514<>;
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[derive(Default)]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct Uint514(pub VecM::<u8>);

impl From<Uint514> for VecM::<u8> {
    #[must_use]
    fn from(x: Uint514) -> Self {
        x.0
    }
}

impl From<VecM::<u8>> for Uint514 {
    #[must_use]
    fn from(x: VecM::<u8>) -> Self {
        Uint514(x)
    }
}

impl AsRef<VecM::<u8>> for Uint514 {
    #[must_use]
    fn as_ref(&self) -> &VecM::<u8> {
        &self.0
    }
}

impl ReadXdr for Uint514 {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = VecM::<u8>::read_xdr(r)?;
        let v = Uint514(i);
        Ok(v)
    }
}

impl WriteXdr for Uint514 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        self.0.write_xdr(w)
    }
}

impl Deref for Uint514 {
  type Target = VecM::<u8>;
  fn deref(&self) -> &Self::Target {
      &self.0
  }
}

impl From<Uint514> for Vec<u8> {
    #[must_use]
    fn from(x: Uint514) -> Self {
        x.0.0
    }
}

impl TryFrom<Vec<u8>> for Uint514 {
    type Error = Error;
    fn try_from(x: Vec<u8>) -> Result<Self> {
        Ok(Uint514(x.try_into()?))
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<u8>> for Uint514 {
    type Error = Error;
    fn try_from(x: &Vec<u8>) -> Result<Self> {
        Ok(Uint514(x.try_into()?))
    }
}

impl AsRef<Vec<u8>> for Uint514 {
    #[must_use]
    fn as_ref(&self) -> &Vec<u8> {
        &self.0.0
    }
}

impl AsRef<[u8]> for Uint514 {
    #[cfg(feature = "alloc")]
    #[must_use]
    fn as_ref(&self) -> &[u8] {
        &self.0.0
    }
    #[cfg(not(feature = "alloc"))]
    #[must_use]
    fn as_ref(&self) -> &[u8] {
        self.0.0
    }
}

// Str is an XDR Typedef defines as:
//
//   typedef string str<64>;
//
pub type Str = VecM::<u8, 64>;

// Str2 is an XDR Typedef defines as:
//
//   typedef string str2<>;
//
pub type Str2 = VecM::<u8>;

// Hash is an XDR Typedef defines as:
//
//   typedef opaque Hash[32];
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct Hash(pub [u8; 32]);

impl From<Hash> for [u8; 32] {
    #[must_use]
    fn from(x: Hash) -> Self {
        x.0
    }
}

impl From<[u8; 32]> for Hash {
    #[must_use]
    fn from(x: [u8; 32]) -> Self {
        Hash(x)
    }
}

impl AsRef<[u8; 32]> for Hash {
    #[must_use]
    fn as_ref(&self) -> &[u8; 32] {
        &self.0
    }
}

impl ReadXdr for Hash {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = <[u8; 32]>::read_xdr(r)?;
        let v = Hash(i);
        Ok(v)
    }
}

impl WriteXdr for Hash {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        self.0.write_xdr(w)
    }
}

impl Hash {
    #[must_use]
    pub fn as_slice(&self) -> &[u8] {
        &self.0
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<Vec<u8>> for Hash {
    type Error = Error;
    fn try_from(x: Vec<u8>) -> Result<Self> {
        x.as_slice().try_into()
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<u8>> for Hash {
    type Error = Error;
    fn try_from(x: &Vec<u8>) -> Result<Self> {
        x.as_slice().try_into()
    }
}

impl TryFrom<&[u8]> for Hash {
    type Error = Error;
    fn try_from(x: &[u8]) -> Result<Self> {
        Ok(Hash(x.try_into()?))
    }
}

impl AsRef<[u8]> for Hash {
    #[must_use]
    fn as_ref(&self) -> &[u8] {
        &self.0
    }
}

// Hashes1 is an XDR Typedef defines as:
//
//   typedef Hash Hashes1[12];
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct Hashes1(pub [Hash; 12]);

impl From<Hashes1> for [Hash; 12] {
    #[must_use]
    fn from(x: Hashes1) -> Self {
        x.0
    }
}

impl From<[Hash; 12]> for Hashes1 {
    #[must_use]
    fn from(x: [Hash; 12]) -> Self {
        Hashes1(x)
    }
}

impl AsRef<[Hash; 12]> for Hashes1 {
    #[must_use]
    fn as_ref(&self) -> &[Hash; 12] {
        &self.0
    }
}

impl ReadXdr for Hashes1 {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = <[Hash; 12]>::read_xdr(r)?;
        let v = Hashes1(i);
        Ok(v)
    }
}

impl WriteXdr for Hashes1 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        self.0.write_xdr(w)
    }
}

impl Hashes1 {
    #[must_use]
    pub fn as_slice(&self) -> &[Hash] {
        &self.0
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<Vec<Hash>> for Hashes1 {
    type Error = Error;
    fn try_from(x: Vec<Hash>) -> Result<Self> {
        x.as_slice().try_into()
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<Hash>> for Hashes1 {
    type Error = Error;
    fn try_from(x: &Vec<Hash>) -> Result<Self> {
        x.as_slice().try_into()
    }
}

impl TryFrom<&[Hash]> for Hashes1 {
    type Error = Error;
    fn try_from(x: &[Hash]) -> Result<Self> {
        Ok(Hashes1(x.try_into()?))
    }
}

impl AsRef<[Hash]> for Hashes1 {
    #[must_use]
    fn as_ref(&self) -> &[Hash] {
        &self.0
    }
}

// Hashes2 is an XDR Typedef defines as:
//
//   typedef Hash Hashes2<12>;
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[derive(Default)]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct Hashes2(pub VecM::<Hash, 12>);

impl From<Hashes2> for VecM::<Hash, 12> {
    #[must_use]
    fn from(x: Hashes2) -> Self {
        x.0
    }
}

impl From<VecM::<Hash, 12>> for Hashes2 {
    #[must_use]
    fn from(x: VecM::<Hash, 12>) -> Self {
        Hashes2(x)
    }
}

impl AsRef<VecM::<Hash, 12>> for Hashes2 {
    #[must_use]
    fn as_ref(&self) -> &VecM::<Hash, 12> {
        &self.0
    }
}

impl ReadXdr for Hashes2 {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = VecM::<Hash, 12>::read_xdr(r)?;
        let v = Hashes2(i);
        Ok(v)
    }
}

impl WriteXdr for Hashes2 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        self.0.write_xdr(w)
    }
}

impl Deref for Hashes2 {
  type Target = VecM::<Hash, 12>;
  fn deref(&self) -> &Self::Target {
      &self.0
  }
}

impl From<Hashes2> for Vec<Hash> {
    #[must_use]
    fn from(x: Hashes2) -> Self {
        x.0.0
    }
}

impl TryFrom<Vec<Hash>> for Hashes2 {
    type Error = Error;
    fn try_from(x: Vec<Hash>) -> Result<Self> {
        Ok(Hashes2(x.try_into()?))
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<Hash>> for Hashes2 {
    type Error = Error;
    fn try_from(x: &Vec<Hash>) -> Result<Self> {
        Ok(Hashes2(x.try_into()?))
    }
}

impl AsRef<Vec<Hash>> for Hashes2 {
    #[must_use]
    fn as_ref(&self) -> &Vec<Hash> {
        &self.0.0
    }
}

impl AsRef<[Hash]> for Hashes2 {
    #[cfg(feature = "alloc")]
    #[must_use]
    fn as_ref(&self) -> &[Hash] {
        &self.0.0
    }
    #[cfg(not(feature = "alloc"))]
    #[must_use]
    fn as_ref(&self) -> &[Hash] {
        self.0.0
    }
}

// Hashes3 is an XDR Typedef defines as:
//
//   typedef Hash Hashes3<>;
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[derive(Default)]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct Hashes3(pub VecM::<Hash>);

impl From<Hashes3> for VecM::<Hash> {
    #[must_use]
    fn from(x: Hashes3) -> Self {
        x.0
    }
}

impl From<VecM::<Hash>> for Hashes3 {
    #[must_use]
    fn from(x: VecM::<Hash>) -> Self {
        Hashes3(x)
    }
}

impl AsRef<VecM::<Hash>> for Hashes3 {
    #[must_use]
    fn as_ref(&self) -> &VecM::<Hash> {
        &self.0
    }
}

impl ReadXdr for Hashes3 {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = VecM::<Hash>::read_xdr(r)?;
        let v = Hashes3(i);
        Ok(v)
    }
}

impl WriteXdr for Hashes3 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        self.0.write_xdr(w)
    }
}

impl Deref for Hashes3 {
  type Target = VecM::<Hash>;
  fn deref(&self) -> &Self::Target {
      &self.0
  }
}

impl From<Hashes3> for Vec<Hash> {
    #[must_use]
    fn from(x: Hashes3) -> Self {
        x.0.0
    }
}

impl TryFrom<Vec<Hash>> for Hashes3 {
    type Error = Error;
    fn try_from(x: Vec<Hash>) -> Result<Self> {
        Ok(Hashes3(x.try_into()?))
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<Hash>> for Hashes3 {
    type Error = Error;
    fn try_from(x: &Vec<Hash>) -> Result<Self> {
        Ok(Hashes3(x.try_into()?))
    }
}

impl AsRef<Vec<Hash>> for Hashes3 {
    #[must_use]
    fn as_ref(&self) -> &Vec<Hash> {
        &self.0.0
    }
}

impl AsRef<[Hash]> for Hashes3 {
    #[cfg(feature = "alloc")]
    #[must_use]
    fn as_ref(&self) -> &[Hash] {
        &self.0.0
    }
    #[cfg(not(feature = "alloc"))]
    #[must_use]
    fn as_ref(&self) -> &[Hash] {
        self.0.0
    }
}

// OptHash1 is an XDR Typedef defines as:
//
//   typedef Hash *optHash1;
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct OptHash1(pub Option<Hash>);

impl From<OptHash1> for Option<Hash> {
    #[must_use]
    fn from(x: OptHash1) -> Self {
        x.0
    }
}

impl From<Option<Hash>> for OptHash1 {
    #[must_use]
    fn from(x: Option<Hash>) -> Self {
        OptHash1(x)
    }
}

impl AsRef<Option<Hash>> for OptHash1 {
    #[must_use]
    fn as_ref(&self) -> &Option<Hash> {
        &self.0
    }
}

impl ReadXdr for OptHash1 {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = Option::<Hash>::read_xdr(r)?;
        let v = OptHash1(i);
        Ok(v)
    }
}

impl WriteXdr for OptHash1 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        self.0.write_xdr(w)
    }
}

// OptHash2 is an XDR Typedef defines as:
//
//   typedef Hash* optHash2;
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct OptHash2(pub Option<Hash>);

impl From<OptHash2> for Option<Hash> {
    #[must_use]
    fn from(x: OptHash2) -> Self {
        x.0
    }
}

impl From<Option<Hash>> for OptHash2 {
    #[must_use]
    fn from(x: Option<Hash>) -> Self {
        OptHash2(x)
    }
}

impl AsRef<Option<Hash>> for OptHash2 {
    #[must_use]
    fn as_ref(&self) -> &Option<Hash> {
        &self.0
    }
}

impl ReadXdr for OptHash2 {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let i = Option::<Hash>::read_xdr(r)?;
        let v = OptHash2(i);
        Ok(v)
    }
}

impl WriteXdr for OptHash2 {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        self.0.write_xdr(w)
    }
}

// Int1 is an XDR Typedef defines as:
//
//   typedef int             int1;
//
pub type Int1 = i32;

// Int2 is an XDR Typedef defines as:
//
//   typedef hyper           int2;
//
pub type Int2 = i64;

// Int3 is an XDR Typedef defines as:
//
//   typedef unsigned int    int3;
//
pub type Int3 = u32;

// Int4 is an XDR Typedef defines as:
//
//   typedef unsigned hyper  int4;
//
pub type Int4 = u64;

// MyStruct is an XDR Struct defines as:
//
//   struct MyStruct
//    {
//        uint512 field1;
//        optHash1 field2;
//        int1 field3;
//        unsigned int field4;
//        float field5;
//        double field6;
//        bool field7;
//    };
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct MyStruct {
  pub field1: Uint512,
  pub field2: OptHash1,
  pub field3: i32,
  pub field4: u32,
  pub field5: f32,
  pub field6: f64,
  pub field7: bool,
}

        impl ReadXdr for MyStruct {
            #[cfg(feature = "std")]
            fn read_xdr(r: &mut impl Read) -> Result<Self> {
                Ok(Self{
                  field1: Uint512::read_xdr(r)?,
field2: OptHash1::read_xdr(r)?,
field3: i32::read_xdr(r)?,
field4: u32::read_xdr(r)?,
field5: f32::read_xdr(r)?,
field6: f64::read_xdr(r)?,
field7: bool::read_xdr(r)?,
                })
            }
        }

        impl WriteXdr for MyStruct {
            #[cfg(feature = "std")]
            fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
                self.field1.write_xdr(w)?;
self.field2.write_xdr(w)?;
self.field3.write_xdr(w)?;
self.field4.write_xdr(w)?;
self.field5.write_xdr(w)?;
self.field6.write_xdr(w)?;
self.field7.write_xdr(w)?;
                Ok(())
            }
        }

// LotsOfMyStructs is an XDR Struct defines as:
//
//   struct LotsOfMyStructs
//    {
//        MyStruct members<>;
//    };
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct LotsOfMyStructs {
  pub members: VecM::<MyStruct>,
}

impl ReadXdr for LotsOfMyStructs {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        Ok(Self{
          members: VecM::<MyStruct>::read_xdr(r)?,
        })
    }
}

impl WriteXdr for LotsOfMyStructs {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        self.members.write_xdr(w)?;
        Ok(())
    }
}

// HasStuff is an XDR Struct defines as:
//
//   struct HasStuff
//    {
//      LotsOfMyStructs data;
//    };
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct HasStuff {
  pub data: LotsOfMyStructs,
}

impl ReadXdr for HasStuff {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        Ok(Self{
          data: LotsOfMyStructs::read_xdr(r)?,
        })
    }
}

impl WriteXdr for HasStuff {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        self.data.write_xdr(w)?;
        Ok(())
    }
}

// Color is an XDR Enum defines as:
//
//   enum Color {
//      RED,
//      BLUE = 5,
//      GREEN
//    };
//
// enum
#[derive(Clone, Copy, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
#[repr(i32)]
pub enum Color {
  Red = 0,
  Blue = 5,
  Green = 6,
}

        impl Color {
            #[must_use]
            pub const fn name(&self) -> &'static str {
                match self {
                    Self::Red => "Red",
Self::Blue => "Blue",
Self::Green => "Green",
                }
            }

            #[must_use]
            pub const fn variants() -> [Color; 3] {
                const VARIANTS: [Color; 3] = [
                    Color::Red,
Color::Blue,
Color::Green,
                ];
                VARIANTS
            }
        }

        impl Name for Color {
            #[must_use]
            fn name(&self) -> &'static str {
                Self::name(self)
            }
        }

        impl Variants<Color> for Color {
            fn variants() -> slice::Iter<'static, Color> {
                const VARIANTS: [Color; 3] = Color::variants();
                VARIANTS.iter()
            }
        }

        impl Enum for Color {}

        impl fmt::Display for Color {
            fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                f.write_str(self.name())
            }
        }

        impl TryFrom<i32> for Color {
            type Error = Error;

            fn try_from(i: i32) -> Result<Self> {
                let e = match i {
                    0 => Color::Red,
5 => Color::Blue,
6 => Color::Green,
                    #[allow(unreachable_patterns)]
                    _ => return Err(Error::Invalid),
                };
                Ok(e)
            }
        }

        impl From<Color> for i32 {
            #[must_use]
            fn from(e: Color) -> Self {
                e as Self
            }
        }

        impl ReadXdr for Color {
            #[cfg(feature = "std")]
            fn read_xdr(r: &mut impl Read) -> Result<Self> {
                let e = i32::read_xdr(r)?;
                let v: Self = e.try_into()?;
                Ok(v)
            }
        }

        impl WriteXdr for Color {
            #[cfg(feature = "std")]
            fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
                let i: i32 = (*self).into();
                i.write_xdr(w)
            }
        }

// Foo is an XDR Const defines as:
//
//   const FOO = 1244;
//
pub const FOO: u64 = 1244;

// Bar is an XDR Const defines as:
//
//   const BAR = FOO;
//
pub const BAR: u64 = FOO;

// NesterNestedEnum is an XDR NestedEnum defines as:
//
//   enum {
//        BLAH_1,
//        BLAH_2
//      }
//
// enum
#[derive(Clone, Copy, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
#[repr(i32)]
pub enum NesterNestedEnum {
  1 = 0,
  2 = 1,
}

        impl NesterNestedEnum {
            #[must_use]
            pub const fn name(&self) -> &'static str {
                match self {
                    Self::1 => "1",
Self::2 => "2",
                }
            }

            #[must_use]
            pub const fn variants() -> [NesterNestedEnum; 2] {
                const VARIANTS: [NesterNestedEnum; 2] = [
                    NesterNestedEnum::1,
NesterNestedEnum::2,
                ];
                VARIANTS
            }
        }

        impl Name for NesterNestedEnum {
            #[must_use]
            fn name(&self) -> &'static str {
                Self::name(self)
            }
        }

        impl Variants<NesterNestedEnum> for NesterNestedEnum {
            fn variants() -> slice::Iter<'static, NesterNestedEnum> {
                const VARIANTS: [NesterNestedEnum; 2] = NesterNestedEnum::variants();
                VARIANTS.iter()
            }
        }

        impl Enum for NesterNestedEnum {}

        impl fmt::Display for NesterNestedEnum {
            fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                f.write_str(self.name())
            }
        }

        impl TryFrom<i32> for NesterNestedEnum {
            type Error = Error;

            fn try_from(i: i32) -> Result<Self> {
                let e = match i {
                    0 => NesterNestedEnum::1,
1 => NesterNestedEnum::2,
                    #[allow(unreachable_patterns)]
                    _ => return Err(Error::Invalid),
                };
                Ok(e)
            }
        }

        impl From<NesterNestedEnum> for i32 {
            #[must_use]
            fn from(e: NesterNestedEnum) -> Self {
                e as Self
            }
        }

        impl ReadXdr for NesterNestedEnum {
            #[cfg(feature = "std")]
            fn read_xdr(r: &mut impl Read) -> Result<Self> {
                let e = i32::read_xdr(r)?;
                let v: Self = e.try_into()?;
                Ok(v)
            }
        }

        impl WriteXdr for NesterNestedEnum {
            #[cfg(feature = "std")]
            fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
                let i: i32 = (*self).into();
                i.write_xdr(w)
            }
        }

// NesterNestedStruct is an XDR NestedStruct defines as:
//
//   struct {
//        int blah;
//      }
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct NesterNestedStruct {
  pub blah: i32,
}

impl ReadXdr for NesterNestedStruct {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        Ok(Self{
          blah: i32::read_xdr(r)?,
        })
    }
}

impl WriteXdr for NesterNestedStruct {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        self.blah.write_xdr(w)?;
        Ok(())
    }
}

// NesterNestedUnion is an XDR NestedUnion defines as:
//
//   union switch (Color color) {
//        case RED:
//          void;
//        default:
//          int blah2;
//      }
//
// union with discriminant Color
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
#[allow(clippy::large_enum_variant)]
pub enum NesterNestedUnion {
  Red,
}

impl NesterNestedUnion {
    #[must_use]
    pub const fn name(&self) -> &'static str {
        match self {
            Self::Red => "Red",
        }
    }

    #[must_use]
    pub const fn discriminant(&self) -> Color {
        #[allow(clippy::match_same_arms)]
        match self {
            Self::Red => Color::Red,
        }
    }

    #[must_use]
    pub const fn variants() -> [Color; 1] {
        const VARIANTS: [Color; 1] = [
            Color::Red,
        ];
        VARIANTS
    }
}

impl Name for NesterNestedUnion {
    #[must_use]
    fn name(&self) -> &'static str {
        Self::name(self)
    }
}

impl Discriminant<Color> for NesterNestedUnion {
    #[must_use]
    fn discriminant(&self) -> Color {
        Self::discriminant(self)
    }
}

impl Variants<Color> for NesterNestedUnion {
    fn variants() -> slice::Iter<'static, Color> {
        const VARIANTS: [Color; 1] = NesterNestedUnion::variants();
        VARIANTS.iter()
    }
}

impl Union<Color> for NesterNestedUnion {}

impl ReadXdr for NesterNestedUnion {
    #[cfg(feature = "std")]
    fn read_xdr(r: &mut impl Read) -> Result<Self> {
        let dv: Color = <Color as ReadXdr>::read_xdr(r)?;
        #[allow(clippy::match_same_arms, clippy::match_wildcard_for_single_variants)]
        let v = match dv {
            Color::Red => Self::Red,
            #[allow(unreachable_patterns)]
            _ => return Err(Error::Invalid),
        };
        Ok(v)
    }
}

impl WriteXdr for NesterNestedUnion {
    #[cfg(feature = "std")]
    fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
        self.discriminant().write_xdr(w)?;
        #[allow(clippy::match_same_arms)]
        match self {
            Self::Red => ().write_xdr(w)?,
        };
        Ok(())
    }
}

// Nester is an XDR Struct defines as:
//
//   struct Nester
//    {
//      enum {
//        BLAH_1,
//        BLAH_2
//      } nestedEnum;
//    
//      struct {
//        int blah;
//      } nestedStruct;
//    
//      union switch (Color color) {
//        case RED:
//          void;
//        default:
//          int blah2;
//      } nestedUnion;
//    
//    
//    };
//
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "camelCase"))]
pub struct Nester {
  pub nested_enum: NesterNestedEnum,
  pub nested_struct: NesterNestedStruct,
  pub nested_union: NesterNestedUnion,
}

        impl ReadXdr for Nester {
            #[cfg(feature = "std")]
            fn read_xdr(r: &mut impl Read) -> Result<Self> {
                Ok(Self{
                  nested_enum: NesterNestedEnum::read_xdr(r)?,
nested_struct: NesterNestedStruct::read_xdr(r)?,
nested_union: NesterNestedUnion::read_xdr(r)?,
                })
            }
        }

        impl WriteXdr for Nester {
            #[cfg(feature = "std")]
            fn write_xdr(&self, w: &mut impl Write) -> Result<()> {
                self.nested_enum.write_xdr(w)?;
self.nested_struct.write_xdr(w)?;
self.nested_union.write_xdr(w)?;
                Ok(())
            }
        }

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
#[cfg(feature = "std")]
use std::string::FromUtf8Error;

#[cfg(feature = "arbitrary")]
use arbitrary::Arbitrary;

#[cfg(all(feature = "schemars", feature = "alloc", feature = "std"))]
use std::borrow::Cow;
#[cfg(all(feature = "schemars", feature = "alloc", not(feature = "std")))]
use alloc::borrow::Cow;

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
    Unsupported,
    LengthExceedsMax,
    LengthMismatch,
    NonZeroPadding,
    Utf8Error(core::str::Utf8Error),
    #[cfg(feature = "alloc")]
    InvalidHex,
    #[cfg(feature = "std")]
    Io(io::Error),
    DepthLimitExceeded,
    #[cfg(feature = "serde_json")]
    Json(serde_json::Error),
    LengthLimitExceeded,
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
            #[cfg(feature = "serde_json")]
            Self::Json(e) => Some(e),
            _ => None,
        }
    }
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Error::Invalid => write!(f, "xdr value invalid"),
            Error::Unsupported => write!(f, "xdr value unsupported"),
            Error::LengthExceedsMax => write!(f, "xdr value max length exceeded"),
            Error::LengthMismatch => write!(f, "xdr value length does not match"),
            Error::NonZeroPadding => write!(f, "xdr padding contains non-zero bytes"),
            Error::Utf8Error(e) => write!(f, "{e}"),
            #[cfg(feature = "alloc")]
            Error::InvalidHex => write!(f, "hex invalid"),
            #[cfg(feature = "std")]
            Error::Io(e) => write!(f, "{e}"),
            Error::DepthLimitExceeded => write!(f, "depth limit exceeded"),
            #[cfg(feature = "serde_json")]
            Error::Json(e) => write!(f, "{e}"),
            Error::LengthLimitExceeded => write!(f, "length limit exceeded"),
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

#[cfg(feature = "serde_json")]
impl From<serde_json::Error> for Error {
    #[must_use]
    fn from(e: serde_json::Error) -> Self {
        Error::Json(e)
    }
}

impl From<Error> for () {
    fn from(_: Error) {}
}

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

/// `Limits` contains the limits that a limited reader or writer will be
/// constrained to.
#[cfg(feature = "std")]
#[derive(Debug, Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
pub struct Limits {
    /// Defines the maximum depth for recursive calls in `Read/WriteXdr` to
    /// prevent stack overflow.
    ///
    /// The depth limit is akin to limiting stack depth. Its purpose is to
    /// prevent the program from hitting the maximum stack size allowed by Rust,
    /// which would result in an unrecoverable `SIGABRT`.  For more information
    /// about Rust's stack size limit, refer to the [Rust
    /// documentation](https://doc.rust-lang.org/std/thread/#stack-size).
    pub depth: u32,

    /// Defines the maximum number of bytes that will be read or written.
    pub len: usize,
}

#[cfg(feature = "std")]
impl Limits {
    #[must_use]
    pub fn none() -> Self {
        Self {
            depth: u32::MAX,
            len: usize::MAX,
        }
    }

    #[must_use]
    pub fn depth(depth: u32) -> Self {
        Limits {
            depth,
            ..Limits::none()
        }
    }

    #[must_use]
    pub fn len(len: usize) -> Self {
        Limits {
            len,
            ..Limits::none()
        }
    }
}

/// `Limited` wraps an object and provides functions for enforcing limits.
///
/// Intended for use with readers and writers and limiting their reads and
/// writes.
#[cfg(feature = "std")]
pub struct Limited<L> {
    pub inner: L,
    pub(crate) limits: Limits,
}

#[cfg(feature = "std")]
impl<L> Limited<L> {
    /// Constructs a new `Limited`.
    ///
    /// - `inner`: The value being limited.
    /// - `limits`: The limits to enforce.
    pub fn new(inner: L, limits: Limits) -> Self {
        Limited { inner, limits }
    }

    /// Consume the given length from the internal remaining length limit.
    ///
    /// ### Errors
    ///
    /// If the length would consume more length than the remaining length limit
    /// allows.
    pub(crate) fn consume_len(&mut self, len: usize) -> Result<(), Error> {
        if let Some(len) = self.limits.len.checked_sub(len) {
            self.limits.len = len;
            Ok(())
        } else {
            Err(Error::LengthLimitExceeded)
        }
    }

    /// Consumes a single depth for the duration of the given function.
    ///
    /// ### Errors
    ///
    /// If the depth limit is already exhausted.
    pub(crate) fn with_limited_depth<T, F>(&mut self, f: F) -> Result<T, Error>
    where
        F: FnOnce(&mut Self) -> Result<T, Error>,
    {
        if let Some(depth) = self.limits.depth.checked_sub(1) {
            self.limits.depth = depth;
            let res = f(self);
            self.limits.depth = self.limits.depth.saturating_add(1);
            res
        } else {
            Err(Error::DepthLimitExceeded)
        }
    }
}

#[cfg(feature = "std")]
impl<R: Read> Read for Limited<R> {
    /// Forwards the read operation to the wrapped object.
    fn read(&mut self, buf: &mut [u8]) -> std::io::Result<usize> {
        self.inner.read(buf)
    }
}

#[cfg(feature = "std")]
impl<R: BufRead> BufRead for Limited<R> {
    /// Forwards the read operation to the wrapped object.
    fn fill_buf(&mut self) -> std::io::Result<&[u8]> {
        self.inner.fill_buf()
    }

    /// Forwards the read operation to the wrapped object.
    fn consume(&mut self, amt: usize) {
        self.inner.consume(amt);
    }
}

#[cfg(feature = "std")]
impl<W: Write> Write for Limited<W> {
    /// Forwards the write operation to the wrapped object.
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        self.inner.write(buf)
    }

    /// Forwards the flush operation to the wrapped object.
    fn flush(&mut self) -> std::io::Result<()> {
        self.inner.flush()
    }
}

#[cfg(feature = "std")]
pub struct ReadXdrIter<R: Read, S: ReadXdr> {
    reader: Limited<BufReader<R>>,
    _s: PhantomData<S>,
}

#[cfg(feature = "std")]
impl<R: Read, S: ReadXdr> ReadXdrIter<R, S> {
    fn new(r: R, limits: Limits) -> Self {
        Self {
            reader: Limited {
                inner: BufReader::new(r),
                limits,
            },
            _s: PhantomData,
        }
    }
}

#[cfg(feature = "std")]
impl<R: Read, S: ReadXdr> Iterator for ReadXdrIter<R, S> {
    type Item = Result<S, Error>;

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
        let r = self.reader.with_limited_depth(|dlr| S::read_xdr(dlr));
        match r {
            Ok(s) => Some(Ok(s)),
            Err(e) => Some(Err(e)),
        }
    }
}

pub trait ReadXdr
where
    Self: Sized,
{
    /// Read the XDR and construct the type.
    ///
    /// Read bytes from the given read implementation, decoding the bytes as
    /// XDR, and construct the type implementing this interface from those
    /// bytes.
    ///
    /// Just enough bytes are read from the read implementation to construct the
    /// type. Any residual bytes remain in the read implementation.
    ///
    /// All implementations should continue if the read implementation returns
    /// [`ErrorKind::Interrupted`](std::io::ErrorKind::Interrupted).
    ///
    /// Use [`ReadXdR: Read_xdr_to_end`] when the intent is for all bytes in the
    /// read implementation to be consumed by the read.
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error>;

    /// Construct the type from the XDR bytes base64 encoded.
    ///
    /// An error is returned if the bytes are not completely consumed by the
    /// deserialization.
    #[cfg(feature = "base64")]
    fn read_xdr_base64<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        let mut dec = Limited::new(
            base64::read::DecoderReader::new(&mut r.inner, base64::STANDARD),
            r.limits.clone(),
        );
        let t = Self::read_xdr(&mut dec)?;
        Ok(t)
    }

    /// Read the XDR and construct the type, and consider it an error if the
    /// read does not completely consume the read implementation.
    ///
    /// Read bytes from the given read implementation, decoding the bytes as
    /// XDR, and construct the type implementing this interface from those
    /// bytes.
    ///
    /// Just enough bytes are read from the read implementation to construct the
    /// type, and then confirm that no further bytes remain. To confirm no
    /// further bytes remain additional bytes are attempted to be read from the
    /// read implementation. If it is possible to read any residual bytes from
    /// the read implementation an error is returned. The read implementation
    /// may not be exhaustively read if there are residual bytes, and it is
    /// considered undefined how many residual bytes or how much of the residual
    /// buffer are consumed in this case.
    ///
    /// All implementations should continue if the read implementation returns
    /// [`ErrorKind::Interrupted`](std::io::ErrorKind::Interrupted).
    #[cfg(feature = "std")]
    fn read_xdr_to_end<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        let s = Self::read_xdr(r)?;
        // Check that any further reads, such as this read of one byte, read no
        // data, indicating EOF. If a byte is read the data is invalid.
        if r.read(&mut [0u8; 1])? == 0 {
            Ok(s)
        } else {
            Err(Error::Invalid)
        }
    }

    /// Construct the type from the XDR bytes base64 encoded.
    ///
    /// An error is returned if the bytes are not completely consumed by the
    /// deserialization.
    #[cfg(feature = "base64")]
    fn read_xdr_base64_to_end<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        let mut dec = Limited::new(
            base64::read::DecoderReader::new(&mut r.inner, base64::STANDARD),
            r.limits.clone(),
        );
        let t = Self::read_xdr_to_end(&mut dec)?;
        Ok(t)
    }

    /// Read the XDR and construct the type.
    ///
    /// Read bytes from the given read implementation, decoding the bytes as
    /// XDR, and construct the type implementing this interface from those
    /// bytes.
    ///
    /// Just enough bytes are read from the read implementation to construct the
    /// type. Any residual bytes remain in the read implementation.
    ///
    /// All implementations should continue if the read implementation returns
    /// [`ErrorKind::Interrupted`](std::io::ErrorKind::Interrupted).
    ///
    /// Use [`ReadXdR: Read_xdr_into_to_end`] when the intent is for all bytes
    /// in the read implementation to be consumed by the read.
    #[cfg(feature = "std")]
    fn read_xdr_into<R: Read>(&mut self, r: &mut Limited<R>) -> Result<(), Error> {
        *self = Self::read_xdr(r)?;
        Ok(())
    }

    /// Read the XDR into the existing value, and consider it an error if the
    /// read does not completely consume the read implementation.
    ///
    /// Read bytes from the given read implementation, decoding the bytes as
    /// XDR, and construct the type implementing this interface from those
    /// bytes.
    ///
    /// Just enough bytes are read from the read implementation to construct the
    /// type, and then confirm that no further bytes remain. To confirm no
    /// further bytes remain additional bytes are attempted to be read from the
    /// read implementation. If it is possible to read any residual bytes from
    /// the read implementation an error is returned. The read implementation
    /// may not be exhaustively read if there are residual bytes, and it is
    /// considered undefined how many residual bytes or how much of the residual
    /// buffer are consumed in this case.
    ///
    /// All implementations should continue if the read implementation returns
    /// [`ErrorKind::Interrupted`](std::io::ErrorKind::Interrupted).
    #[cfg(feature = "std")]
    fn read_xdr_into_to_end<R: Read>(&mut self, r: &mut Limited<R>) -> Result<(), Error> {
        Self::read_xdr_into(self, r)?;
        // Check that any further reads, such as this read of one byte, read no
        // data, indicating EOF. If a byte is read the data is invalid.
        if r.read(&mut [0u8; 1])? == 0 {
            Ok(())
        } else {
            Err(Error::Invalid)
        }
    }

    /// Create an iterator that reads the read implementation as a stream of
    /// values that are read into the implementing type.
    ///
    /// Read bytes from the given read implementation, decoding the bytes as
    /// XDR, and construct the type implementing this interface from those
    /// bytes.
    ///
    /// Just enough bytes are read from the read implementation to construct the
    /// type, and then confirm that no further bytes remain. To confirm no
    /// further bytes remain additional bytes are attempted to be read from the
    /// read implementation. If it is possible to read any residual bytes from
    /// the read implementation an error is returned. The read implementation
    /// may not be exhaustively read if there are residual bytes, and it is
    /// considered undefined how many residual bytes or how much of the residual
    /// buffer are consumed in this case.
    ///
    /// All implementations should continue if the read implementation returns
    /// [`ErrorKind::Interrupted`](std::io::ErrorKind::Interrupted).
    #[cfg(feature = "std")]
    fn read_xdr_iter<R: Read>(r: &mut Limited<R>) -> ReadXdrIter<&mut R, Self> {
        ReadXdrIter::new(&mut r.inner, r.limits.clone())
    }

    /// Create an iterator that reads the read implementation as a stream of
    /// values that are read into the implementing type.
    #[cfg(feature = "base64")]
    fn read_xdr_base64_iter<R: Read>(
        r: &mut Limited<R>,
    ) -> ReadXdrIter<base64::read::DecoderReader<R>, Self> {
        let dec = base64::read::DecoderReader::new(&mut r.inner, base64::STANDARD);
        ReadXdrIter::new(dec, r.limits.clone())
    }

    /// Construct the type from the XDR bytes.
    ///
    /// An error is returned if the bytes are not completely consumed by the
    /// deserialization.
    #[cfg(feature = "std")]
    fn from_xdr(bytes: impl AsRef<[u8]>, limits: Limits) -> Result<Self, Error> {
        let mut cursor = Limited::new(Cursor::new(bytes.as_ref()), limits);
        let t = Self::read_xdr_to_end(&mut cursor)?;
        Ok(t)
    }

    /// Construct the type from the XDR bytes base64 encoded.
    ///
    /// An error is returned if the bytes are not completely consumed by the
    /// deserialization.
    #[cfg(feature = "base64")]
    fn from_xdr_base64(b64: impl AsRef<[u8]>, limits: Limits) -> Result<Self, Error> {
        let mut b64_reader = Cursor::new(b64);
        let mut dec = Limited::new(
            base64::read::DecoderReader::new(&mut b64_reader, base64::STANDARD),
            limits,
        );
        let t = Self::read_xdr_to_end(&mut dec)?;
        Ok(t)
    }
}

pub trait WriteXdr {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error>;

    #[cfg(feature = "std")]
    fn to_xdr(&self, limits: Limits) -> Result<Vec<u8>, Error> {
        let mut cursor = Limited::new(Cursor::new(vec![]), limits);
        self.write_xdr(&mut cursor)?;
        let bytes = cursor.inner.into_inner();
        Ok(bytes)
    }

    #[cfg(feature = "base64")]
    fn to_xdr_base64(&self, limits: Limits) -> Result<String, Error> {
        let mut enc = Limited::new(
            base64::write::EncoderStringWriter::new(base64::STANDARD),
            limits,
        );
        self.write_xdr(&mut enc)?;
        let b64 = enc.inner.into_inner();
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
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        let mut b = [0u8; 4];
        r.with_limited_depth(|r| {
            r.consume_len(b.len())?;
            r.read_exact(&mut b)?;
            Ok(i32::from_be_bytes(b))
        })
    }
}

impl WriteXdr for i32 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        let b: [u8; 4] = self.to_be_bytes();
        w.with_limited_depth(|w| {
            w.consume_len(b.len())?;
            Ok(w.write_all(&b)?)
        })
    }
}

impl ReadXdr for u32 {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        let mut b = [0u8; 4];
        r.with_limited_depth(|r| {
            r.consume_len(b.len())?;
            r.read_exact(&mut b)?;
            Ok(u32::from_be_bytes(b))
        })
    }
}

impl WriteXdr for u32 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        let b: [u8; 4] = self.to_be_bytes();
        w.with_limited_depth(|w| {
            w.consume_len(b.len())?;
            Ok(w.write_all(&b)?)
        })
    }
}

impl ReadXdr for i64 {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        let mut b = [0u8; 8];
        r.with_limited_depth(|r| {
            r.consume_len(b.len())?;
            r.read_exact(&mut b)?;
            Ok(i64::from_be_bytes(b))
        })
    }
}

impl WriteXdr for i64 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        let b: [u8; 8] = self.to_be_bytes();
        w.with_limited_depth(|w| {
            w.consume_len(b.len())?;
            Ok(w.write_all(&b)?)
        })
    }
}

impl ReadXdr for u64 {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        let mut b = [0u8; 8];
        r.with_limited_depth(|r| {
            r.consume_len(b.len())?;
            r.read_exact(&mut b)?;
            Ok(u64::from_be_bytes(b))
        })
    }
}

impl WriteXdr for u64 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        let b: [u8; 8] = self.to_be_bytes();
        w.with_limited_depth(|w| {
            w.consume_len(b.len())?;
            Ok(w.write_all(&b)?)
        })
    }
}

impl ReadXdr for f32 {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(_r: &mut Limited<R>) -> Result<Self, Error> {
        todo!()
    }
}

impl WriteXdr for f32 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, _w: &mut Limited<W>) -> Result<(), Error> {
        todo!()
    }
}

impl ReadXdr for f64 {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(_r: &mut Limited<R>) -> Result<Self, Error> {
        todo!()
    }
}

impl WriteXdr for f64 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, _w: &mut Limited<W>) -> Result<(), Error> {
        todo!()
    }
}

impl ReadXdr for bool {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let i = u32::read_xdr(r)?;
            let b = i == 1;
            Ok(b)
        })
    }
}

impl WriteXdr for bool {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w| {
            let i = u32::from(*self); // true = 1, false = 0
            i.write_xdr(w)
        })
    }
}

impl<T: ReadXdr> ReadXdr for Option<T> {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let i = u32::read_xdr(r)?;
            match i {
                0 => Ok(None),
                1 => {
                    let t = T::read_xdr(r)?;
                    Ok(Some(t))
                }
                _ => Err(Error::Invalid),
            }
        })
    }
}

impl<T: WriteXdr> WriteXdr for Option<T> {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w| {
            if let Some(t) = self {
                1u32.write_xdr(w)?;
                t.write_xdr(w)?;
            } else {
                0u32.write_xdr(w)?;
            }
            Ok(())
        })
    }
}

impl<T: ReadXdr> ReadXdr for Box<T> {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| Ok(Box::new(T::read_xdr(r)?)))
    }
}

impl<T: WriteXdr> WriteXdr for Box<T> {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w| T::write_xdr(self, w))
    }
}

impl ReadXdr for () {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(_r: &mut Limited<R>) -> Result<Self, Error> {
        Ok(())
    }
}

impl WriteXdr for () {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, _w: &mut Limited<W>) -> Result<(), Error> {
        Ok(())
    }
}

impl<const N: usize> ReadXdr for [u8; N] {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            r.consume_len(N)?;
            let padding = pad_len(N);
            r.consume_len(padding)?;
            let mut arr = [0u8; N];
            r.read_exact(&mut arr)?;
            let pad = &mut [0u8; 3][..padding];
            r.read_exact(pad)?;
            if pad.iter().any(|b| *b != 0) {
                return Err(Error::NonZeroPadding);
            }
            Ok(arr)
        })
    }
}

impl<const N: usize> WriteXdr for [u8; N] {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w| {
            w.consume_len(N)?;
            let padding = pad_len(N);
            w.consume_len(padding)?;
            w.write_all(self)?;
            w.write_all(&[0u8; 3][..padding])?;
            Ok(())
        })
    }
}

impl<T: ReadXdr, const N: usize> ReadXdr for [T; N] {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let mut vec = Vec::with_capacity(N);
            for _ in 0..N {
                let t = T::read_xdr(r)?;
                vec.push(t);
            }
            let arr: [T; N] = vec.try_into().unwrap_or_else(|_: Vec<T>| unreachable!());
            Ok(arr)
        })
    }
}

impl<T: WriteXdr, const N: usize> WriteXdr for [T; N] {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w| {
            for t in self {
                t.write_xdr(w)?;
            }
            Ok(())
        })
    }
}

// VecM ------------------------------------------------------------------------

#[cfg(feature = "alloc")]
#[derive(Debug, Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "serde", serde_with::serde_as, derive(serde::Serialize, serde::Deserialize))]
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

#[cfg(feature = "schemars")]
impl<T: schemars::JsonSchema, const MAX: u32> schemars::JsonSchema for VecM<T, MAX> {
    fn schema_name() -> String {
        format!("VecM<{}, {}>", T::schema_name(), MAX)
    }

    fn is_referenceable() -> bool {
        false
    }

    fn json_schema(gen: &mut schemars::gen::SchemaGenerator) -> schemars::schema::Schema {
        let schema = Vec::<T>::json_schema(gen);
        if let schemars::schema::Schema::Object(mut schema) = schema {
            if let Some(array) = schema.array.clone() {
                schema.array = Some(Box::new(schemars::schema::ArrayValidation {
                    max_items: Some(MAX),
                    ..*array
                }));
            }
            schema.into()
        } else {
            schema
        }
    }
}

#[cfg(feature = "schemars")]
impl<T, TA, const MAX: u32> serde_with::schemars_0_8::JsonSchemaAs<VecM<T, MAX>> for VecM<TA, MAX>
where
    TA: serde_with::schemars_0_8::JsonSchemaAs<T>,
{
    fn schema_name() -> String {
        <VecM<serde_with::Schema<T, TA>, MAX> as schemars::JsonSchema>::schema_name()
    }

    fn schema_id() -> Cow<'static, str> {
        <VecM<serde_with::Schema<T, TA>, MAX> as schemars::JsonSchema>::schema_id()
    }

    fn json_schema(gen: &mut schemars::gen::SchemaGenerator) -> schemars::schema::Schema {
        <VecM<serde_with::Schema<T, TA>, MAX> as schemars::JsonSchema>::json_schema(gen)
    }

    fn is_referenceable() -> bool {
        <VecM<serde_with::Schema<T, TA>, MAX> as schemars::JsonSchema>::is_referenceable()
    }
}

#[cfg(feature = "serde")]
impl<T, U, const MAX: u32> serde_with::SerializeAs<VecM<T, MAX>> for VecM<U, MAX>
where
    U: serde_with::SerializeAs<T>,
{
    fn serialize_as<S>(source: &VecM<T, MAX>, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.collect_seq(source.iter().map(|item| serde_with::ser::SerializeAsWrap::<T, U>::new(item)))
    }
}

#[cfg(feature = "serde")]
impl<'de, T, U, const MAX: u32> serde_with::DeserializeAs<'de, VecM<T, MAX>> for VecM<U, MAX>
where
    U: serde_with::DeserializeAs<'de, T>,
{
    fn deserialize_as<D>(deserializer: D) -> Result<VecM<T, MAX>, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        let vec = <Vec<U> as serde_with::DeserializeAs<Vec<T>>>::deserialize_as(deserializer)?;
        Ok(vec.try_into().map_err(|e| serde::de::Error::custom(e))?)
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

#[cfg(feature = "alloc")]
impl<T, const MAX: u32> VecM<T, MAX> {
    pub fn iter_mut(&mut self) -> core::slice::IterMut<'_, T> {
        self.0.iter_mut()
    }
}

#[cfg(feature = "alloc")]
impl<'a, T, const MAX: u32> core::iter::IntoIterator for &'a mut VecM<T, MAX> {
    type Item = &'a mut T;
    type IntoIter = core::slice::IterMut<'a, T>;
    fn into_iter(self) -> Self::IntoIter {
        self.iter_mut()
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
    pub fn to_string(&self) -> Result<String, Error> {
        self.try_into()
    }

    #[cfg(feature = "alloc")]
    pub fn into_string(self) -> Result<String, Error> {
        self.try_into()
    }

    #[cfg(feature = "alloc")]
    #[must_use]
    pub fn to_string_lossy(&self) -> String {
        String::from_utf8_lossy(&self.0).into_owned()
    }

    #[cfg(feature = "alloc")]
    #[must_use]
    pub fn into_string_lossy(self) -> String {
        String::from_utf8_lossy(&self.0).into_owned()
    }
}

impl<T: Clone> VecM<T, 1> {
    #[must_use]
    pub fn to_option(&self) -> Option<T> {
        if self.len() > 0 {
            Some(self.0[0].clone())
        } else {
            None
        }
    }
}

#[cfg(not(feature = "alloc"))]
impl<T: Clone> From<VecM<T, 1>> for Option<T> {
    #[must_use]
    fn from(v: VecM<T, 1>) -> Self {
        v.to_option()
    }
}

#[cfg(feature = "alloc")]
impl<T> VecM<T, 1> {
    #[must_use]
    pub fn into_option(mut self) -> Option<T> {
        self.0.drain(..).next()
    }
}

#[cfg(feature = "alloc")]
impl<T> From<VecM<T, 1>> for Option<T> {
    #[must_use]
    fn from(v: VecM<T, 1>) -> Self {
        v.into_option()
    }
}

impl<T, const MAX: u32> TryFrom<Vec<T>> for VecM<T, MAX> {
    type Error = Error;

    fn try_from(v: Vec<T>) -> Result<Self, Error> {
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

    fn try_from(v: &Vec<T>) -> Result<Self, Error> {
        v.as_slice().try_into()
    }
}

#[cfg(feature = "alloc")]
impl<T: Clone, const MAX: u32> TryFrom<&[T]> for VecM<T, MAX> {
    type Error = Error;

    fn try_from(v: &[T]) -> Result<Self, Error> {
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

    fn try_from(v: [T; N]) -> Result<Self, Error> {
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

    fn try_from(v: &[T; N]) -> Result<Self, Error> {
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

    fn try_from(v: &'static [T; N]) -> Result<Self, Error> {
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

    fn try_from(v: &String) -> Result<Self, Error> {
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

    fn try_from(v: String) -> Result<Self, Error> {
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

    fn try_from(v: VecM<u8, MAX>) -> Result<Self, Error> {
        Ok(String::from_utf8(v.0)?)
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&VecM<u8, MAX>> for String {
    type Error = Error;

    fn try_from(v: &VecM<u8, MAX>) -> Result<Self, Error> {
        Ok(core::str::from_utf8(v.as_ref())?.to_owned())
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&str> for VecM<u8, MAX> {
    type Error = Error;

    fn try_from(v: &str) -> Result<Self, Error> {
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

    fn try_from(v: &'static str) -> Result<Self, Error> {
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

    fn try_from(v: &'a VecM<u8, MAX>) -> Result<Self, Error> {
        Ok(core::str::from_utf8(v.as_ref())?)
    }
}

impl<const MAX: u32> ReadXdr for VecM<u8, MAX> {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let len: u32 = u32::read_xdr(r)?;
            if len > MAX {
                return Err(Error::LengthExceedsMax);
            }

            r.consume_len(len as usize)?;
            let padding = pad_len(len as usize);
            r.consume_len(padding)?;

            let mut vec = vec![0u8; len as usize];
            r.read_exact(&mut vec)?;

            let pad = &mut [0u8; 3][..padding];
            r.read_exact(pad)?;
            if pad.iter().any(|b| *b != 0) {
                return Err(Error::NonZeroPadding);
            }

            Ok(VecM(vec))
        })
    }
}

impl<const MAX: u32> WriteXdr for VecM<u8, MAX> {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w| {
            let len: u32 = self.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
            len.write_xdr(w)?;

            w.consume_len(self.len())?;
            let padding = pad_len(self.len());
            w.consume_len(padding)?;

            w.write_all(&self.0)?;

            w.write_all(&[0u8; 3][..padding])?;

            Ok(())
        })
    }
}

impl<T: ReadXdr, const MAX: u32> ReadXdr for VecM<T, MAX> {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let len = u32::read_xdr(r)?;
            if len > MAX {
                return Err(Error::LengthExceedsMax);
            }

            let mut vec = Vec::new();
            for _ in 0..len {
                let t = T::read_xdr(r)?;
                vec.push(t);
            }

            Ok(VecM(vec))
        })
    }
}

impl<T: WriteXdr, const MAX: u32> WriteXdr for VecM<T, MAX> {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w| {
            let len: u32 = self.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
            len.write_xdr(w)?;

            for t in &self.0 {
                t.write_xdr(w)?;
            }

            Ok(())
        })
    }
}

// BytesM ------------------------------------------------------------------------

#[cfg(feature = "alloc")]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(
    feature = "serde",
    derive(serde_with::SerializeDisplay, serde_with::DeserializeFromStr)
)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
pub struct BytesM<const MAX: u32 = { u32::MAX }>(Vec<u8>);

#[cfg(not(feature = "alloc"))]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
pub struct BytesM<const MAX: u32 = { u32::MAX }>(Vec<u8>);

impl<const MAX: u32> core::fmt::Display for BytesM<MAX> {
    fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
        #[cfg(feature = "alloc")]
        let v = &self.0;
        #[cfg(not(feature = "alloc"))]
        let v = self.0;
        for b in v {
            write!(f, "{b:02x}")?;
        }
        Ok(())
    }
}

impl<const MAX: u32> core::fmt::Debug for BytesM<MAX> {
    fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
        #[cfg(feature = "alloc")]
        let v = &self.0;
        #[cfg(not(feature = "alloc"))]
        let v = self.0;
        write!(f, "BytesM(")?;
        for b in v {
            write!(f, "{b:02x}")?;
        }
        write!(f, ")")?;
        Ok(())
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> core::str::FromStr for BytesM<MAX> {
    type Err = Error;
    fn from_str(s: &str) -> core::result::Result<Self, Self::Err> {
        hex::decode(s).map_err(|_| Error::InvalidHex)?.try_into()
    }
}

impl<const MAX: u32> Deref for BytesM<MAX> {
    type Target = Vec<u8>;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

#[cfg(feature = "schemars")]
impl<const MAX: u32> schemars::JsonSchema for BytesM<MAX> {
    fn schema_name() -> String {
        format!("BytesM<{MAX}>")
    }

    fn is_referenceable() -> bool {
        false
    }

    fn json_schema(gen: &mut schemars::gen::SchemaGenerator) -> schemars::schema::Schema {
        let schema = String::json_schema(gen);
        if let schemars::schema::Schema::Object(mut schema) = schema {
            schema.extensions.insert(
                "contentEncoding".to_owned(),
                serde_json::Value::String("hex".to_string()),
            );
            schema.extensions.insert(
                "contentMediaType".to_owned(),
                serde_json::Value::String("application/binary".to_string()),
            );
            let string = *schema.string.unwrap_or_default().clone();
            schema.string = Some(Box::new(schemars::schema::StringValidation {
                max_length: MAX.checked_mul(2).map(Some).unwrap_or_default(),
                min_length: None,
                ..string
            }));
            schema.into()
        } else {
            schema
        }
    }
}

impl<const MAX: u32> Default for BytesM<MAX> {
    fn default() -> Self {
        Self(Vec::default())
    }
}

impl<const MAX: u32> BytesM<MAX> {
    pub const MAX_LEN: usize = { MAX as usize };

    #[must_use]
    #[allow(clippy::unused_self)]
    pub fn max_len(&self) -> usize {
        Self::MAX_LEN
    }

    #[must_use]
    pub fn as_vec(&self) -> &Vec<u8> {
        self.as_ref()
    }
}

impl<const MAX: u32> BytesM<MAX> {
    #[must_use]
    #[cfg(feature = "alloc")]
    pub fn to_vec(&self) -> Vec<u8> {
        self.into()
    }

    #[must_use]
    pub fn into_vec(self) -> Vec<u8> {
        self.into()
    }
}

impl<const MAX: u32> BytesM<MAX> {
    #[cfg(feature = "alloc")]
    pub fn to_string(&self) -> Result<String, Error> {
        self.try_into()
    }

    #[cfg(feature = "alloc")]
    pub fn into_string(self) -> Result<String, Error> {
        self.try_into()
    }

    #[cfg(feature = "alloc")]
    #[must_use]
    pub fn to_string_lossy(&self) -> String {
        String::from_utf8_lossy(&self.0).into_owned()
    }

    #[cfg(feature = "alloc")]
    #[must_use]
    pub fn into_string_lossy(self) -> String {
        String::from_utf8_lossy(&self.0).into_owned()
    }
}

impl<const MAX: u32> TryFrom<Vec<u8>> for BytesM<MAX> {
    type Error = Error;

    fn try_from(v: Vec<u8>) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(BytesM(v))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

impl<const MAX: u32> From<BytesM<MAX>> for Vec<u8> {
    #[must_use]
    fn from(v: BytesM<MAX>) -> Self {
        v.0
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> From<&BytesM<MAX>> for Vec<u8> {
    #[must_use]
    fn from(v: &BytesM<MAX>) -> Self {
        v.0.clone()
    }
}

impl<const MAX: u32> AsRef<Vec<u8>> for BytesM<MAX> {
    #[must_use]
    fn as_ref(&self) -> &Vec<u8> {
        &self.0
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&Vec<u8>> for BytesM<MAX> {
    type Error = Error;

    fn try_from(v: &Vec<u8>) -> Result<Self, Error> {
        v.as_slice().try_into()
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&[u8]> for BytesM<MAX> {
    type Error = Error;

    fn try_from(v: &[u8]) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(BytesM(v.to_vec()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

impl<const MAX: u32> AsRef<[u8]> for BytesM<MAX> {
    #[cfg(feature = "alloc")]
    #[must_use]
    fn as_ref(&self) -> &[u8] {
        self.0.as_ref()
    }
    #[cfg(not(feature = "alloc"))]
    #[must_use]
    fn as_ref(&self) -> &[u8] {
        self.0
    }
}

#[cfg(feature = "alloc")]
impl<const N: usize, const MAX: u32> TryFrom<[u8; N]> for BytesM<MAX> {
    type Error = Error;

    fn try_from(v: [u8; N]) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(BytesM(v.to_vec()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(feature = "alloc")]
impl<const N: usize, const MAX: u32> TryFrom<BytesM<MAX>> for [u8; N] {
    type Error = BytesM<MAX>;

    fn try_from(v: BytesM<MAX>) -> core::result::Result<Self, Self::Error> {
        let s: [u8; N] = v.0.try_into().map_err(BytesM::<MAX>)?;
        Ok(s)
    }
}

#[cfg(feature = "alloc")]
impl<const N: usize, const MAX: u32> TryFrom<&[u8; N]> for BytesM<MAX> {
    type Error = Error;

    fn try_from(v: &[u8; N]) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(BytesM(v.to_vec()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(not(feature = "alloc"))]
impl<const N: usize, const MAX: u32> TryFrom<&'static [u8; N]> for BytesM<MAX> {
    type Error = Error;

    fn try_from(v: &'static [u8; N]) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(BytesM(v))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&String> for BytesM<MAX> {
    type Error = Error;

    fn try_from(v: &String) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(BytesM(v.as_bytes().to_vec()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<String> for BytesM<MAX> {
    type Error = Error;

    fn try_from(v: String) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(BytesM(v.into()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<BytesM<MAX>> for String {
    type Error = Error;

    fn try_from(v: BytesM<MAX>) -> Result<Self, Error> {
        Ok(String::from_utf8(v.0)?)
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&BytesM<MAX>> for String {
    type Error = Error;

    fn try_from(v: &BytesM<MAX>) -> Result<Self, Error> {
        Ok(core::str::from_utf8(v.as_ref())?.to_owned())
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&str> for BytesM<MAX> {
    type Error = Error;

    fn try_from(v: &str) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(BytesM(v.into()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(not(feature = "alloc"))]
impl<const MAX: u32> TryFrom<&'static str> for BytesM<MAX> {
    type Error = Error;

    fn try_from(v: &'static str) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(BytesM(v.as_bytes()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

impl<'a, const MAX: u32> TryFrom<&'a BytesM<MAX>> for &'a str {
    type Error = Error;

    fn try_from(v: &'a BytesM<MAX>) -> Result<Self, Error> {
        Ok(core::str::from_utf8(v.as_ref())?)
    }
}

impl<const MAX: u32> ReadXdr for BytesM<MAX> {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let len: u32 = u32::read_xdr(r)?;
            if len > MAX {
                return Err(Error::LengthExceedsMax);
            }

            r.consume_len(len as usize)?;
            let padding = pad_len(len as usize);
            r.consume_len(padding)?;

            let mut vec = vec![0u8; len as usize];
            r.read_exact(&mut vec)?;

            let pad = &mut [0u8; 3][..padding];
            r.read_exact(pad)?;
            if pad.iter().any(|b| *b != 0) {
                return Err(Error::NonZeroPadding);
            }

            Ok(BytesM(vec))
        })
    }
}

impl<const MAX: u32> WriteXdr for BytesM<MAX> {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w| {
            let len: u32 = self.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
            len.write_xdr(w)?;

            w.consume_len(self.len())?;
            let padding = pad_len(self.len());
            w.consume_len(padding)?;

            w.write_all(&self.0)?;

            w.write_all(&[0u8; 3][..pad_len(len as usize)])?;

            Ok(())
        })
    }
}

// StringM ------------------------------------------------------------------------

/// A string type that contains arbitrary bytes.
///
/// Convertible, fallibly, to/from a Rust UTF-8 String using
/// [`TryFrom`]/[`TryInto`]/[`StringM::to_utf8_string`].
///
/// Convertible, lossyly, to a Rust UTF-8 String using
/// [`StringM::to_utf8_string_lossy`].
///
/// Convertible to/from escaped printable-ASCII using
/// [`Display`]/[`ToString`]/[`FromStr`].

#[cfg(feature = "alloc")]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(
    feature = "serde",
    derive(serde_with::SerializeDisplay, serde_with::DeserializeFromStr)
)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
pub struct StringM<const MAX: u32 = { u32::MAX }>(Vec<u8>);

#[cfg(not(feature = "alloc"))]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
pub struct StringM<const MAX: u32 = { u32::MAX }>(Vec<u8>);

impl<const MAX: u32> core::fmt::Display for StringM<MAX> {
    fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
        #[cfg(feature = "alloc")]
        let v = &self.0;
        #[cfg(not(feature = "alloc"))]
        let v = self.0;
        for b in escape_bytes::Escape::new(v) {
            write!(f, "{}", b as char)?;
        }
        Ok(())
    }
}

impl<const MAX: u32> core::fmt::Debug for StringM<MAX> {
    fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
        #[cfg(feature = "alloc")]
        let v = &self.0;
        #[cfg(not(feature = "alloc"))]
        let v = self.0;
        write!(f, "StringM(")?;
        for b in escape_bytes::Escape::new(v) {
            write!(f, "{}", b as char)?;
        }
        write!(f, ")")?;
        Ok(())
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> core::str::FromStr for StringM<MAX> {
    type Err = Error;
    fn from_str(s: &str) -> core::result::Result<Self, Self::Err> {
        let b = escape_bytes::unescape(s.as_bytes()).map_err(|_| Error::Invalid)?;
        Ok(Self(b))
    }
}

impl<const MAX: u32> Deref for StringM<MAX> {
    type Target = Vec<u8>;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl<const MAX: u32> Default for StringM<MAX> {
    fn default() -> Self {
        Self(Vec::default())
    }
}

#[cfg(feature = "schemars")]
impl<const MAX: u32> schemars::JsonSchema for StringM<MAX> {
    fn schema_name() -> String {
        format!("StringM<{MAX}>")
    }

    fn json_schema(gen: &mut schemars::gen::SchemaGenerator) -> schemars::schema::Schema {
        let schema = String::json_schema(gen);
        if let schemars::schema::Schema::Object(mut schema) = schema {
            let string = *schema.string.unwrap_or_default().clone();
            schema.string = Some(Box::new(schemars::schema::StringValidation {
                max_length: Some(MAX),
                ..string
            }));
            schema.into()
        } else {
            schema
        }
    }
}

impl<const MAX: u32> StringM<MAX> {
    pub const MAX_LEN: usize = { MAX as usize };

    #[must_use]
    #[allow(clippy::unused_self)]
    pub fn max_len(&self) -> usize {
        Self::MAX_LEN
    }

    #[must_use]
    pub fn as_vec(&self) -> &Vec<u8> {
        self.as_ref()
    }
}

impl<const MAX: u32> StringM<MAX> {
    #[must_use]
    #[cfg(feature = "alloc")]
    pub fn to_vec(&self) -> Vec<u8> {
        self.into()
    }

    #[must_use]
    pub fn into_vec(self) -> Vec<u8> {
        self.into()
    }
}

impl<const MAX: u32> StringM<MAX> {
    #[cfg(feature = "alloc")]
    pub fn to_utf8_string(&self) -> Result<String, Error> {
        self.try_into()
    }

    #[cfg(feature = "alloc")]
    pub fn into_utf8_string(self) -> Result<String, Error> {
        self.try_into()
    }

    #[cfg(feature = "alloc")]
    #[must_use]
    pub fn to_utf8_string_lossy(&self) -> String {
        String::from_utf8_lossy(&self.0).into_owned()
    }

    #[cfg(feature = "alloc")]
    #[must_use]
    pub fn into_utf8_string_lossy(self) -> String {
        String::from_utf8_lossy(&self.0).into_owned()
    }
}

impl<const MAX: u32> TryFrom<Vec<u8>> for StringM<MAX> {
    type Error = Error;

    fn try_from(v: Vec<u8>) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(StringM(v))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

impl<const MAX: u32> From<StringM<MAX>> for Vec<u8> {
    #[must_use]
    fn from(v: StringM<MAX>) -> Self {
        v.0
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> From<&StringM<MAX>> for Vec<u8> {
    #[must_use]
    fn from(v: &StringM<MAX>) -> Self {
        v.0.clone()
    }
}

impl<const MAX: u32> AsRef<Vec<u8>> for StringM<MAX> {
    #[must_use]
    fn as_ref(&self) -> &Vec<u8> {
        &self.0
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&Vec<u8>> for StringM<MAX> {
    type Error = Error;

    fn try_from(v: &Vec<u8>) -> Result<Self, Error> {
        v.as_slice().try_into()
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&[u8]> for StringM<MAX> {
    type Error = Error;

    fn try_from(v: &[u8]) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(StringM(v.to_vec()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

impl<const MAX: u32> AsRef<[u8]> for StringM<MAX> {
    #[cfg(feature = "alloc")]
    #[must_use]
    fn as_ref(&self) -> &[u8] {
        self.0.as_ref()
    }
    #[cfg(not(feature = "alloc"))]
    #[must_use]
    fn as_ref(&self) -> &[u8] {
        self.0
    }
}

#[cfg(feature = "alloc")]
impl<const N: usize, const MAX: u32> TryFrom<[u8; N]> for StringM<MAX> {
    type Error = Error;

    fn try_from(v: [u8; N]) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(StringM(v.to_vec()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(feature = "alloc")]
impl<const N: usize, const MAX: u32> TryFrom<StringM<MAX>> for [u8; N] {
    type Error = StringM<MAX>;

    fn try_from(v: StringM<MAX>) -> core::result::Result<Self, Self::Error> {
        let s: [u8; N] = v.0.try_into().map_err(StringM::<MAX>)?;
        Ok(s)
    }
}

#[cfg(feature = "alloc")]
impl<const N: usize, const MAX: u32> TryFrom<&[u8; N]> for StringM<MAX> {
    type Error = Error;

    fn try_from(v: &[u8; N]) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(StringM(v.to_vec()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(not(feature = "alloc"))]
impl<const N: usize, const MAX: u32> TryFrom<&'static [u8; N]> for StringM<MAX> {
    type Error = Error;

    fn try_from(v: &'static [u8; N]) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(StringM(v))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&String> for StringM<MAX> {
    type Error = Error;

    fn try_from(v: &String) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(StringM(v.as_bytes().to_vec()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<String> for StringM<MAX> {
    type Error = Error;

    fn try_from(v: String) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(StringM(v.into()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<StringM<MAX>> for String {
    type Error = Error;

    fn try_from(v: StringM<MAX>) -> Result<Self, Error> {
        Ok(String::from_utf8(v.0)?)
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&StringM<MAX>> for String {
    type Error = Error;

    fn try_from(v: &StringM<MAX>) -> Result<Self, Error> {
        Ok(core::str::from_utf8(v.as_ref())?.to_owned())
    }
}

#[cfg(feature = "alloc")]
impl<const MAX: u32> TryFrom<&str> for StringM<MAX> {
    type Error = Error;

    fn try_from(v: &str) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(StringM(v.into()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

#[cfg(not(feature = "alloc"))]
impl<const MAX: u32> TryFrom<&'static str> for StringM<MAX> {
    type Error = Error;

    fn try_from(v: &'static str) -> Result<Self, Error> {
        let len: u32 = v.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
        if len <= MAX {
            Ok(StringM(v.as_bytes()))
        } else {
            Err(Error::LengthExceedsMax)
        }
    }
}

impl<'a, const MAX: u32> TryFrom<&'a StringM<MAX>> for &'a str {
    type Error = Error;

    fn try_from(v: &'a StringM<MAX>) -> Result<Self, Error> {
        Ok(core::str::from_utf8(v.as_ref())?)
    }
}

impl<const MAX: u32> ReadXdr for StringM<MAX> {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let len: u32 = u32::read_xdr(r)?;
            if len > MAX {
                return Err(Error::LengthExceedsMax);
            }

            r.consume_len(len as usize)?;
            let padding = pad_len(len as usize);
            r.consume_len(padding)?;

            let mut vec = vec![0u8; len as usize];
            r.read_exact(&mut vec)?;

            let pad = &mut [0u8; 3][..padding];
            r.read_exact(pad)?;
            if pad.iter().any(|b| *b != 0) {
                return Err(Error::NonZeroPadding);
            }

            Ok(StringM(vec))
        })
    }
}

impl<const MAX: u32> WriteXdr for StringM<MAX> {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w| {
            let len: u32 = self.len().try_into().map_err(|_| Error::LengthExceedsMax)?;
            len.write_xdr(w)?;

            w.consume_len(self.len())?;
            let padding = pad_len(self.len());
            w.consume_len(padding)?;

            w.write_all(&self.0)?;

            w.write_all(&[0u8; 3][..padding])?;

            Ok(())
        })
    }
}

// Frame ------------------------------------------------------------------------

#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(
    all(feature = "serde", feature = "alloc"),
    derive(serde::Serialize, serde::Deserialize),
    serde(rename_all = "snake_case")
)]
pub struct Frame<T>(pub T)
where
    T: ReadXdr;

#[cfg(feature = "schemars")]
impl<T: schemars::JsonSchema + ReadXdr> schemars::JsonSchema for Frame<T> {
    fn schema_name() -> String {
        format!("Frame<{}>", T::schema_name())
    }

    fn json_schema(gen: &mut schemars::gen::SchemaGenerator) -> schemars::schema::Schema {
        T::json_schema(gen)
    }
}

impl<T> ReadXdr for Frame<T>
where
    T: ReadXdr,
{
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        // Read the frame header value that contains 1 flag-bit and a 33-bit length.
        //  - The 1 flag bit is 0 when there are more frames for the same record.
        //  - The 31-bit length is the length of the bytes within the frame that
        //  follow the frame header.
        let header = u32::read_xdr(r)?;
        // TODO: Use the length and cap the length we'll read from `r`.
        let last_record = header >> 31 == 1;
        if last_record {
            // Read the record in the frame.
            Ok(Self(T::read_xdr(r)?))
        } else {
            // TODO: Support reading those additional frames for the same
            // record.
            Err(Error::Unsupported)
        }
    }
}

// NumberOrString ---------------------------------------------------------------

/// NumberOrString is a serde_as serializer/deserializer.
///
/// It deserializers any integer that fits into a 64-bit value into an i64 or u64 field from either
/// a JSON Number or JSON String value.
///
/// It serializes always to a string.
///
/// It has a JsonSchema implementation that only advertises that the allowed format is a String.
/// This is because the type is intended to soften the changing of fields from JSON Number to JSON
/// String by permitting deserialization, but discourage new uses of JSON Number.
#[cfg(feature = "serde")]
struct NumberOrString;

#[cfg(feature = "serde")]
impl<'de> serde_with::DeserializeAs<'de, i64> for NumberOrString {
    fn deserialize_as<D>(deserializer: D) -> Result<i64, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        struct Vis;
        impl<'de> serde::de::Visitor<'de> for Vis {
            type Value = i64;

            fn expecting(&self, formatter: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
                formatter.write_str("a number or number string")
            }

            fn visit_i8<E>(self, v: i8) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_u8<E>(self, v: u8) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_i16<E>(self, v: i16) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_u16<E>(self, v: u16) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_i32<E>(self, v: i32) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_u32<E>(self, v: u32) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_i64<E>(self, v: i64) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v)
            }

            fn visit_u64<E>(self, v: u64) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_str<E>(self, v: &str) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.parse().map_err(|e| serde::de::Error::custom(e))?)
            }

            fn visit_string<E>(self, v: String) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.parse().map_err(|e| serde::de::Error::custom(e))?)
            }
        }
        deserializer.deserialize_any(Vis)
    }
}

#[cfg(feature = "serde")]
impl<'de> serde_with::DeserializeAs<'de, u64> for NumberOrString {
    fn deserialize_as<D>(deserializer: D) -> Result<u64, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        struct Vis;
        impl<'de> serde::de::Visitor<'de> for Vis {
            type Value = u64;

            fn expecting(&self, formatter: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
                formatter.write_str("a number or number string")
            }

            fn visit_i8<E>(self, v: i8) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_u8<E>(self, v: u8) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_i16<E>(self, v: i16) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_u16<E>(self, v: u16) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_i32<E>(self, v: i32) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_u32<E>(self, v: u32) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_i64<E>(self, v: i64) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.try_into().map_err(|e|serde::de::Error::custom(e))?)
            }

            fn visit_u64<E>(self, v: u64) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v)
            }

            fn visit_str<E>(self, v: &str) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.parse().map_err(|e| serde::de::Error::custom(e))?)
            }

            fn visit_string<E>(self, v: String) -> Result<Self::Value, E> where E: serde::de::Error {
                Ok(v.parse().map_err(|e| serde::de::Error::custom(e))?)
            }
        }
        deserializer.deserialize_any(Vis)
    }
}

#[cfg(feature = "serde")]
impl serde_with::SerializeAs<i64> for NumberOrString {
    fn serialize_as<S>(source: &i64, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        use serde::Serialize;
        source.to_string().serialize(serializer)
    }
}

#[cfg(feature = "serde")]
impl serde_with::SerializeAs<u64> for NumberOrString {
    fn serialize_as<S>(source: &u64, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        use serde::Serialize;
        source.to_string().serialize(serializer)
    }
}

#[cfg(feature = "schemars")]
impl<T> serde_with::schemars_0_8::JsonSchemaAs<T> for NumberOrString {
    fn schema_name() -> String {
        <String as schemars::JsonSchema>::schema_name()
    }

    fn schema_id() -> std::borrow::Cow<'static, str> {
        <String as schemars::JsonSchema>::schema_id()
    }

    fn json_schema(gen: &mut schemars::gen::SchemaGenerator) -> schemars::schema::Schema {
        <String as schemars::JsonSchema>::json_schema(gen)
    }

    fn is_referenceable() -> bool {
        <String as schemars::JsonSchema>::is_referenceable()
    }
}

// Tests ------------------------------------------------------------------------

#[cfg(all(test, feature = "std"))]
mod tests {
    use std::io::Cursor;

    use super::*;

    #[test]
    pub fn vec_u8_read_without_padding() {
        let buf = Cursor::new(vec![0, 0, 0, 4, 2, 2, 2, 2]);
        let v = VecM::<u8, 8>::read_xdr(&mut Limited::new(buf, Limits::none())).unwrap();
        assert_eq!(v.to_vec(), vec![2, 2, 2, 2]);
    }

    #[test]
    pub fn vec_u8_read_with_padding() {
        let buf = Cursor::new(vec![0, 0, 0, 1, 2, 0, 0, 0]);
        let v = VecM::<u8, 8>::read_xdr(&mut Limited::new(buf, Limits::none())).unwrap();
        assert_eq!(v.to_vec(), vec![2]);
    }

    #[test]
    pub fn vec_u8_read_with_insufficient_padding() {
        let buf = Cursor::new(vec![0, 0, 0, 1, 2, 0, 0]);
        let res = VecM::<u8, 8>::read_xdr(&mut Limited::new(buf, Limits::none()));
        match res {
            Err(Error::Io(_)) => (),
            _ => panic!("expected IO error got {res:?}"),
        }
    }

    #[test]
    pub fn vec_u8_read_with_non_zero_padding() {
        let buf = Cursor::new(vec![0, 0, 0, 1, 2, 3, 0, 0]);
        let res = VecM::<u8, 8>::read_xdr(&mut Limited::new(buf, Limits::none()));
        match res {
            Err(Error::NonZeroPadding) => (),
            _ => panic!("expected NonZeroPadding got {res:?}"),
        }
    }

    #[test]
    pub fn vec_u8_write_without_padding() {
        let mut buf = vec![];
        let v: VecM<u8, 8> = vec![2, 2, 2, 2].try_into().unwrap();

        v.write_xdr(&mut Limited::new(Cursor::new(&mut buf), Limits::none()))
            .unwrap();
        assert_eq!(buf, vec![0, 0, 0, 4, 2, 2, 2, 2]);
    }

    #[test]
    pub fn vec_u8_write_with_padding() {
        let mut buf = vec![];
        let v: VecM<u8, 8> = vec![2].try_into().unwrap();
        v.write_xdr(&mut Limited::new(Cursor::new(&mut buf), Limits::none()))
            .unwrap();
        assert_eq!(buf, vec![0, 0, 0, 1, 2, 0, 0, 0]);
    }

    #[test]
    pub fn arr_u8_read_without_padding() {
        let buf = Cursor::new(vec![2, 2, 2, 2]);
        let v = <[u8; 4]>::read_xdr(&mut Limited::new(buf, Limits::none())).unwrap();
        assert_eq!(v, [2, 2, 2, 2]);
    }

    #[test]
    pub fn arr_u8_read_with_padding() {
        let buf = Cursor::new(vec![2, 0, 0, 0]);
        let v = <[u8; 1]>::read_xdr(&mut Limited::new(buf, Limits::none())).unwrap();
        assert_eq!(v, [2]);
    }

    #[test]
    pub fn arr_u8_read_with_insufficient_padding() {
        let buf = Cursor::new(vec![2, 0, 0]);
        let res = <[u8; 1]>::read_xdr(&mut Limited::new(buf, Limits::none()));
        match res {
            Err(Error::Io(_)) => (),
            _ => panic!("expected IO error got {res:?}"),
        }
    }

    #[test]
    pub fn arr_u8_read_with_non_zero_padding() {
        let buf = Cursor::new(vec![2, 3, 0, 0]);
        let res = <[u8; 1]>::read_xdr(&mut Limited::new(buf, Limits::none()));
        match res {
            Err(Error::NonZeroPadding) => (),
            _ => panic!("expected NonZeroPadding got {res:?}"),
        }
    }

    #[test]
    pub fn arr_u8_write_without_padding() {
        let mut buf = vec![];
        [2u8, 2, 2, 2]
            .write_xdr(&mut Limited::new(Cursor::new(&mut buf), Limits::none()))
            .unwrap();
        assert_eq!(buf, vec![2, 2, 2, 2]);
    }

    #[test]
    pub fn arr_u8_write_with_padding() {
        let mut buf = vec![];
        [2u8]
            .write_xdr(&mut Limited::new(Cursor::new(&mut buf), Limits::none()))
            .unwrap();
        assert_eq!(buf, vec![2, 0, 0, 0]);
    }
}

#[cfg(all(test, feature = "std"))]
mod test {
    use super::*;

    #[test]
    fn into_option_none() {
        let v: VecM<u32, 1> = vec![].try_into().unwrap();
        assert_eq!(v.into_option(), None);
    }

    #[test]
    fn into_option_some() {
        let v: VecM<_, 1> = vec![1].try_into().unwrap();
        assert_eq!(v.into_option(), Some(1));
    }

    #[test]
    fn to_option_none() {
        let v: VecM<u32, 1> = vec![].try_into().unwrap();
        assert_eq!(v.to_option(), None);
    }

    #[test]
    fn to_option_some() {
        let v: VecM<_, 1> = vec![1].try_into().unwrap();
        assert_eq!(v.to_option(), Some(1));
    }

    #[test]
    fn depth_limited_read_write_under_the_limit_success() {
        let a: Option<Option<Option<u32>>> = Some(Some(Some(5)));
        let mut buf = Limited::new(Vec::new(), Limits::depth(4));
        a.write_xdr(&mut buf).unwrap();

        let mut dlr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::depth(4));
        let a_back: Option<Option<Option<u32>>> = ReadXdr::read_xdr(&mut dlr).unwrap();
        assert_eq!(a, a_back);
    }

    #[test]
    fn write_over_depth_limit_fail() {
        let a: Option<Option<Option<u32>>> = Some(Some(Some(5)));
        let mut buf = Limited::new(Vec::new(), Limits::depth(3));
        let res = a.write_xdr(&mut buf);
        match res {
            Err(Error::DepthLimitExceeded) => (),
            _ => panic!("expected DepthLimitExceeded got {res:?}"),
        }
    }

    #[test]
    fn read_over_depth_limit_fail() {
        let read_limits = Limits::depth(3);
        let write_limits = Limits::depth(5);
        let a: Option<Option<Option<u32>>> = Some(Some(Some(5)));
        let mut buf = Limited::new(Vec::new(), write_limits);
        a.write_xdr(&mut buf).unwrap();

        let mut dlr = Limited::new(Cursor::new(buf.inner.as_slice()), read_limits);
        let res: Result<Option<Option<Option<u32>>>, _> = ReadXdr::read_xdr(&mut dlr);
        match res {
            Err(Error::DepthLimitExceeded) => (),
            _ => panic!("expected DepthLimitExceeded got {res:?}"),
        }
    }

    #[test]
    fn length_limited_read_write_i32() {
        // Exact limit, success
        let v = 123i32;
        let mut buf = Limited::new(Vec::new(), Limits::len(4));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(4));
        let v_back: i32 = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 0);
        assert_eq!(v, v_back);

        // Over limit, success
        let v = 123i32;
        let mut buf = Limited::new(Vec::new(), Limits::len(5));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 1);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(5));
        let v_back: i32 = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 1);
        assert_eq!(v, v_back);

        // Write under limit, failure
        let v = 123i32;
        let mut buf = Limited::new(Vec::new(), Limits::len(3));
        assert_eq!(v.write_xdr(&mut buf), Err(Error::LengthLimitExceeded));

        // Read under limit, failure
        let v = 123i32;
        let mut buf = Limited::new(Vec::new(), Limits::len(4));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(3));
        assert_eq!(
            <i32 as ReadXdr>::read_xdr(&mut lr),
            Err(Error::LengthLimitExceeded)
        );
    }

    #[test]
    fn length_limited_read_write_u32() {
        // Exact limit, success
        let v = 123u32;
        let mut buf = Limited::new(Vec::new(), Limits::len(4));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(4));
        let v_back: u32 = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 0);
        assert_eq!(v, v_back);

        // Over limit, success
        let v = 123u32;
        let mut buf = Limited::new(Vec::new(), Limits::len(5));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 1);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(5));
        let v_back: u32 = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 1);
        assert_eq!(v, v_back);

        // Write under limit, failure
        let v = 123u32;
        let mut buf = Limited::new(Vec::new(), Limits::len(3));
        assert_eq!(v.write_xdr(&mut buf), Err(Error::LengthLimitExceeded));

        // Read under limit, failure
        let v = 123u32;
        let mut buf = Limited::new(Vec::new(), Limits::len(4));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(3));
        assert_eq!(
            <u32 as ReadXdr>::read_xdr(&mut lr),
            Err(Error::LengthLimitExceeded)
        );
    }

    #[test]
    fn length_limited_read_write_i64() {
        // Exact limit, success
        let v = 123i64;
        let mut buf = Limited::new(Vec::new(), Limits::len(8));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(8));
        let v_back: i64 = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 0);
        assert_eq!(v, v_back);

        // Over limit, success
        let v = 123i64;
        let mut buf = Limited::new(Vec::new(), Limits::len(9));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 1);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(9));
        let v_back: i64 = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 1);
        assert_eq!(v, v_back);

        // Write under limit, failure
        let v = 123i64;
        let mut buf = Limited::new(Vec::new(), Limits::len(7));
        assert_eq!(v.write_xdr(&mut buf), Err(Error::LengthLimitExceeded));

        // Read under limit, failure
        let v = 123i64;
        let mut buf = Limited::new(Vec::new(), Limits::len(8));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(7));
        assert_eq!(
            <i64 as ReadXdr>::read_xdr(&mut lr),
            Err(Error::LengthLimitExceeded)
        );
    }

    #[test]
    fn length_limited_read_write_u64() {
        // Exact limit, success
        let v = 123u64;
        let mut buf = Limited::new(Vec::new(), Limits::len(8));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(8));
        let v_back: u64 = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 0);
        assert_eq!(v, v_back);

        // Over limit, success
        let v = 123u64;
        let mut buf = Limited::new(Vec::new(), Limits::len(9));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 1);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(9));
        let v_back: u64 = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 1);
        assert_eq!(v, v_back);

        // Write under limit, failure
        let v = 123u64;
        let mut buf = Limited::new(Vec::new(), Limits::len(7));
        assert_eq!(v.write_xdr(&mut buf), Err(Error::LengthLimitExceeded));

        // Read under limit, failure
        let v = 123u64;
        let mut buf = Limited::new(Vec::new(), Limits::len(8));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(7));
        assert_eq!(
            <u64 as ReadXdr>::read_xdr(&mut lr),
            Err(Error::LengthLimitExceeded)
        );
    }

    #[test]
    fn length_limited_read_write_bool() {
        // Exact limit, success
        let v = true;
        let mut buf = Limited::new(Vec::new(), Limits::len(4));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(4));
        let v_back: bool = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 0);
        assert_eq!(v, v_back);

        // Over limit, success
        let v = true;
        let mut buf = Limited::new(Vec::new(), Limits::len(5));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 1);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(5));
        let v_back: bool = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 1);
        assert_eq!(v, v_back);

        // Write under limit, failure
        let v = true;
        let mut buf = Limited::new(Vec::new(), Limits::len(3));
        assert_eq!(v.write_xdr(&mut buf), Err(Error::LengthLimitExceeded));

        // Read under limit, failure
        let v = true;
        let mut buf = Limited::new(Vec::new(), Limits::len(4));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(3));
        assert_eq!(
            <bool as ReadXdr>::read_xdr(&mut lr),
            Err(Error::LengthLimitExceeded)
        );
    }

    #[test]
    fn length_limited_read_write_option() {
        // Exact limit, success
        let v = Some(true);
        let mut buf = Limited::new(Vec::new(), Limits::len(8));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(8));
        let v_back: Option<bool> = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 0);
        assert_eq!(v, v_back);

        // Over limit, success
        let v = Some(true);
        let mut buf = Limited::new(Vec::new(), Limits::len(9));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 1);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(9));
        let v_back: Option<bool> = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 1);
        assert_eq!(v, v_back);

        // Write under limit, failure
        let v = Some(true);
        let mut buf = Limited::new(Vec::new(), Limits::len(7));
        assert_eq!(v.write_xdr(&mut buf), Err(Error::LengthLimitExceeded));

        // Read under limit, failure
        let v = Some(true);
        let mut buf = Limited::new(Vec::new(), Limits::len(8));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(7));
        assert_eq!(
            <Option<bool> as ReadXdr>::read_xdr(&mut lr),
            Err(Error::LengthLimitExceeded)
        );
    }

    #[test]
    fn length_limited_read_write_array_u8() {
        // Exact limit, success
        let v = [1u8, 2, 3];
        let mut buf = Limited::new(Vec::new(), Limits::len(4));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(4));
        let v_back: [u8; 3] = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 0);
        assert_eq!(v, v_back);

        // Over limit, success
        let v = [1u8, 2, 3];
        let mut buf = Limited::new(Vec::new(), Limits::len(5));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 1);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(5));
        let v_back: [u8; 3] = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 1);
        assert_eq!(v, v_back);

        // Write under limit, failure
        let v = [1u8, 2, 3];
        let mut buf = Limited::new(Vec::new(), Limits::len(3));
        assert_eq!(v.write_xdr(&mut buf), Err(Error::LengthLimitExceeded));

        // Read under limit, failure
        let v = [1u8, 2, 3];
        let mut buf = Limited::new(Vec::new(), Limits::len(4));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(3));
        assert_eq!(
            <[u8; 3] as ReadXdr>::read_xdr(&mut lr),
            Err(Error::LengthLimitExceeded)
        );
    }

    #[test]
    fn length_limited_read_write_array_type() {
        // Exact limit, success
        let v = [true, false, true];
        let mut buf = Limited::new(Vec::new(), Limits::len(12));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(12));
        let v_back: [bool; 3] = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 0);
        assert_eq!(v, v_back);

        // Over limit, success
        let v = [true, false, true];
        let mut buf = Limited::new(Vec::new(), Limits::len(13));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 1);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(13));
        let v_back: [bool; 3] = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 1);
        assert_eq!(v, v_back);

        // Write under limit, failure
        let v = [true, false, true];
        let mut buf = Limited::new(Vec::new(), Limits::len(11));
        assert_eq!(v.write_xdr(&mut buf), Err(Error::LengthLimitExceeded));

        // Read under limit, failure
        let v = [true, false, true];
        let mut buf = Limited::new(Vec::new(), Limits::len(12));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(11));
        assert_eq!(
            <[bool; 3] as ReadXdr>::read_xdr(&mut lr),
            Err(Error::LengthLimitExceeded)
        );
    }

    #[test]
    fn length_limited_read_write_vec() {
        // Exact limit, success
        let v = VecM::<i32, 3>::try_from([1i32, 2, 3]).unwrap();
        let mut buf = Limited::new(Vec::new(), Limits::len(16));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(16));
        let v_back: VecM<i32, 3> = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 0);
        assert_eq!(v, v_back);

        // Over limit, success
        let v = VecM::<i32, 3>::try_from([1i32, 2, 3]).unwrap();
        let mut buf = Limited::new(Vec::new(), Limits::len(17));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 1);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(17));
        let v_back: VecM<i32, 3> = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 1);
        assert_eq!(v, v_back);

        // Write under limit, failure
        let v = VecM::<i32, 3>::try_from([1i32, 2, 3]).unwrap();
        let mut buf = Limited::new(Vec::new(), Limits::len(15));
        assert_eq!(v.write_xdr(&mut buf), Err(Error::LengthLimitExceeded));

        // Read under limit, failure
        let v = VecM::<i32, 3>::try_from([1i32, 2, 3]).unwrap();
        let mut buf = Limited::new(Vec::new(), Limits::len(16));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(15));
        assert_eq!(
            <VecM<i32, 3> as ReadXdr>::read_xdr(&mut lr),
            Err(Error::LengthLimitExceeded)
        );
    }

    #[test]
    fn length_limited_read_write_bytes() {
        // Exact limit, success
        let v = BytesM::<3>::try_from([1u8, 2, 3]).unwrap();
        let mut buf = Limited::new(Vec::new(), Limits::len(8));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(8));
        let v_back: BytesM<3> = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 0);
        assert_eq!(v, v_back);

        // Over limit, success
        let v = BytesM::<3>::try_from([1u8, 2, 3]).unwrap();
        let mut buf = Limited::new(Vec::new(), Limits::len(9));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 1);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(9));
        let v_back: BytesM<3> = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 1);
        assert_eq!(v, v_back);

        // Write under limit, failure
        let v = BytesM::<3>::try_from([1u8, 2, 3]).unwrap();
        let mut buf = Limited::new(Vec::new(), Limits::len(7));
        assert_eq!(v.write_xdr(&mut buf), Err(Error::LengthLimitExceeded));

        // Read under limit, failure
        let v = BytesM::<3>::try_from([1u8, 2, 3]).unwrap();
        let mut buf = Limited::new(Vec::new(), Limits::len(8));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(7));
        assert_eq!(
            <BytesM<3> as ReadXdr>::read_xdr(&mut lr),
            Err(Error::LengthLimitExceeded)
        );
    }

    #[test]
    fn length_limited_read_write_string() {
        // Exact limit, success
        let v = StringM::<3>::try_from("123").unwrap();
        let mut buf = Limited::new(Vec::new(), Limits::len(8));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(8));
        let v_back: StringM<3> = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 0);
        assert_eq!(v, v_back);

        // Over limit, success
        let v = StringM::<3>::try_from("123").unwrap();
        let mut buf = Limited::new(Vec::new(), Limits::len(9));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 1);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(9));
        let v_back: StringM<3> = ReadXdr::read_xdr(&mut lr).unwrap();
        assert_eq!(buf.limits.len, 1);
        assert_eq!(v, v_back);

        // Write under limit, failure
        let v = StringM::<3>::try_from("123").unwrap();
        let mut buf = Limited::new(Vec::new(), Limits::len(7));
        assert_eq!(v.write_xdr(&mut buf), Err(Error::LengthLimitExceeded));

        // Read under limit, failure
        let v = StringM::<3>::try_from("123").unwrap();
        let mut buf = Limited::new(Vec::new(), Limits::len(8));
        v.write_xdr(&mut buf).unwrap();
        assert_eq!(buf.limits.len, 0);
        let mut lr = Limited::new(Cursor::new(buf.inner.as_slice()), Limits::len(7));
        assert_eq!(
            <StringM<3> as ReadXdr>::read_xdr(&mut lr),
            Err(Error::LengthLimitExceeded)
        );
    }
}

#[cfg(all(test, not(feature = "alloc")))]
mod test {
    use super::VecM;

    #[test]
    fn to_option_none() {
        let v: VecM<u32, 1> = (&[]).try_into().unwrap();
        assert_eq!(v.to_option(), None);
    }

    #[test]
    fn to_option_some() {
        let v: VecM<_, 1> = (&[1]).try_into().unwrap();
        assert_eq!(v.to_option(), Some(1));
    }
}

#[cfg(all(test, feature = "serde"))]
mod tests_for_number_or_string {
    use super::*;
    use serde::{Deserialize, Serialize};
    use serde_json;
    use serde_with::serde_as;

    // --- Helper Structs ---
    #[serde_as]
    #[derive(Debug, PartialEq, Deserialize, Serialize)]
    struct TestI64 {
        #[serde_as(as = "NumberOrString")]
        val: i64,
    }

    #[serde_as]
    #[derive(Debug, PartialEq, Deserialize, Serialize)]
    struct TestU64 {
        #[serde_as(as = "NumberOrString")]
        val: u64,
    }

    #[serde_as]
    #[derive(Debug, PartialEq, Deserialize, Serialize)]
    struct TestOptionI64 {
        #[serde_as(as = "Option<NumberOrString>")]
        val: Option<i64>,
    }

    #[serde_as]
    #[derive(Debug, PartialEq, Deserialize, Serialize)]
    struct TestOptionU64 {
        #[serde_as(as = "Option<NumberOrString>")]
        val: Option<u64>,
    }

    #[serde_as]
    #[derive(Debug, PartialEq, Deserialize, Serialize)]
    struct TestVecI64 {
        #[serde_as(as = "Vec<NumberOrString>")]
        val: Vec<i64>,
    }

    #[serde_as]
    #[derive(Debug, PartialEq, Deserialize, Serialize)]
    struct TestVecU64 {
        #[serde_as(as = "Vec<NumberOrString>")]
        val: Vec<u64>,
    }

    // Helper Enum for testing field access within variants
    #[serde_as]
    #[derive(Debug, PartialEq, Deserialize, Serialize)]
    #[serde(rename_all = "camelCase")] // Added to make JSON keys distinct for variants
    enum TestEnum {
        VariantA {
            #[serde(rename = "numVal")]
            #[serde_as(as = "NumberOrString")]
            num_val: i64,
            #[serde(rename = "otherData")]
            other_data: String,
        },
        VariantB {
            #[serde_as(as = "NumberOrString")]
            count: u64,
        },
        SimpleVariant,
    }

    // --- i64 Deserialization Tests ---
    #[test]
    fn deserialize_i64_from_json_number_positive() {
        let json = r#"{"val": 123}"#;
        let expected = TestI64 { val: 123 };
        assert_eq!(serde_json::from_str::<TestI64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_i64_from_json_number_negative() {
        let json = r#"{"val": -456}"#;
        let expected = TestI64 { val: -456 };
        assert_eq!(serde_json::from_str::<TestI64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_i64_from_json_number_zero() {
        let json = r#"{"val": 0}"#;
        let expected = TestI64 { val: 0 };
        assert_eq!(serde_json::from_str::<TestI64>(json).unwrap(), expected);
    }
    
    #[test]
    fn deserialize_i64_from_json_number_max() {
        let json = format!(r#"{{"val": {}}}"#, i64::MAX);
        let expected = TestI64 { val: i64::MAX };
        assert_eq!(serde_json::from_str::<TestI64>(&json).unwrap(), expected);
    }

    #[test]
    fn deserialize_i64_from_json_number_min() {
        let json = format!(r#"{{"val": {}}}"#, i64::MIN);
        let expected = TestI64 { val: i64::MIN };
        assert_eq!(serde_json::from_str::<TestI64>(&json).unwrap(), expected);
    }

    #[test]
    fn deserialize_i64_from_json_string_positive() {
        let json = r#"{"val": "789"}"#;
        let expected = TestI64 { val: 789 };
        assert_eq!(serde_json::from_str::<TestI64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_i64_from_json_string_negative() {
        let json = r#"{"val": "-101"}"#;
        let expected = TestI64 { val: -101 };
        assert_eq!(serde_json::from_str::<TestI64>(json).unwrap(), expected);
    }
    
    #[test]
    fn deserialize_i64_from_json_string_zero() {
        let json = r#"{"val": "0"}"#;
        let expected = TestI64 { val: 0 };
        assert_eq!(serde_json::from_str::<TestI64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_i64_from_json_string_max() {
        let json = format!(r#"{{"val": "{}"}}"#, i64::MAX);
        let expected = TestI64 { val: i64::MAX };
        assert_eq!(serde_json::from_str::<TestI64>(&json).unwrap(), expected);
    }

    #[test]
    fn deserialize_i64_from_json_string_min() {
        let json = format!(r#"{{"val": "{}"}}"#, i64::MIN);
        let expected = TestI64 { val: i64::MIN };
        assert_eq!(serde_json::from_str::<TestI64>(&json).unwrap(), expected);
    }

    #[test]
    fn deserialize_i64_from_json_string_with_plus_prefix() {
        let json = r#"{"val": "+123"}"#;
        let expected = TestI64 { val: 123 };
        assert_eq!(serde_json::from_str::<TestI64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_i64_from_json_string_with_plus_zero() {
        let json = r#"{"val": "+0"}"#;
        let expected = TestI64 { val: 0 };
        assert_eq!(serde_json::from_str::<TestI64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_i64_from_json_string_with_minus_zero() {
        let json = r#"{"val": "-0"}"#;
        let expected = TestI64 { val: 0 };
        assert_eq!(serde_json::from_str::<TestI64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_i64_error_from_json_string_with_leading_whitespace() {
        let json = r#"{"val": " 123"}"#;
        assert!(serde_json::from_str::<TestI64>(json).is_err());
    }

    #[test]
    fn deserialize_i64_error_from_json_string_with_trailing_whitespace() {
        let json = r#"{"val": "123 "}"#;
        assert!(serde_json::from_str::<TestI64>(json).is_err());
    }
    
    #[test]
    fn deserialize_i64_error_from_json_string_with_both_whitespace() {
        let json = r#"{"val": " 123 "}"#;
        assert!(serde_json::from_str::<TestI64>(json).is_err());
    }

    #[test]
    fn deserialize_i64_error_from_json_string_with_invalid_plus_prefix() {
        let json = r#"{"val": "++123"}"#;
        assert!(serde_json::from_str::<TestI64>(json).is_err());
    }
    
    #[test]
    fn deserialize_i64_error_from_json_string_with_invalid_minus_prefix() {
        let json = r#"{"val": "--123"}"#;
        assert!(serde_json::from_str::<TestI64>(json).is_err());
    }

    #[test]
    fn deserialize_i64_error_from_json_string_with_invalid_mixed_prefix() {
        let json = r#"{"val": "+-123"}"#;
        assert!(serde_json::from_str::<TestI64>(json).is_err());
    }

    #[test]
    fn deserialize_i64_error_from_string_not_a_number() {
        let json = r#"{"val": "abc"}"#;
        assert!(serde_json::from_str::<TestI64>(json).is_err());
    }

    #[test]
    fn deserialize_i64_error_from_string_float() {
        let json = r#"{"val": "123.45"}"#; // Not an integer
        assert!(serde_json::from_str::<TestI64>(json).is_err());
    }

    #[test]
    fn deserialize_i64_error_from_string_empty() {
        let json = r#"{"val": ""}"#;
        assert!(serde_json::from_str::<TestI64>(json).is_err());
    }

    #[test]
    fn deserialize_i64_error_from_string_overflow() {
        let overflow_val = (i64::MAX as i128) + 1;
        let json = format!(r#"{{"val": "{}"}}"#, overflow_val);
        assert!(serde_json::from_str::<TestI64>(&json).is_err());
    }
    
    #[test]
    fn deserialize_i64_error_from_string_underflow() {
        let underflow_val = (i64::MIN as i128) - 1;
        let json = format!(r#"{{"val": "{}"}}"#, underflow_val);
        assert!(serde_json::from_str::<TestI64>(&json).is_err());
    }

    #[test]
    fn deserialize_i64_error_from_json_float_number() {
        let json = r#"{"val": 123.45}"#;
        let err = serde_json::from_str::<TestI64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid type: floating point"));
    }

    #[test]
    fn deserialize_i64_error_from_json_bool_true() {
        let json = r#"{"val": true}"#;
        let err = serde_json::from_str::<TestI64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid type: boolean `true`"));
    }

    #[test]
    fn deserialize_i64_error_from_json_array() {
        let json = r#"{"val": []}"#;
        let err = serde_json::from_str::<TestI64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid type: sequence"));
    }

    #[test]
    fn deserialize_i64_error_from_json_object() {
        let json = r#"{"val": {}}"#;
        let err = serde_json::from_str::<TestI64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid type: map"));
    }

    #[test]
    fn deserialize_i64_error_from_json_null() {
        let json = r#"{"val": null}"#;
        let err = serde_json::from_str::<TestI64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid type: null"));
    }

    // -- Additional i64 String Format Tests --
    #[test]
    fn deserialize_i64_error_from_hex_string() {
        let json = r#"{"val": "0x1A"}"#; // Hex "26"
        // std::primitive::i64.from_str() does not support "0x"
        assert!(serde_json::from_str::<TestI64>(json).is_err(), "Hex string should fail parsing to i64");
    }

    #[test]
    fn deserialize_i64_error_from_octal_string() {
        let json = r#"{"val": "0o77"}"#; // Octal "63"
        // std::primitive::i64.from_str() does not support "0o"
        assert!(serde_json::from_str::<TestI64>(json).is_err(), "Octal string should fail parsing to i64");
    }

    #[test]
    fn deserialize_i64_error_from_scientific_notation_string() {
        let json = r#"{"val": "1e3"}"#; // "1000" in scientific
        // std::primitive::i64.from_str() does not support scientific notation
        assert!(serde_json::from_str::<TestI64>(json).is_err(), "Scientific notation string should fail parsing to i64");
    }

    #[test]
    fn deserialize_i64_error_from_invalid_scientific_notation_string() {
        let json = r#"{"val": "1e"}"#;
        assert!(serde_json::from_str::<TestI64>(json).is_err(), "Invalid scientific notation string should fail");
    }

    #[test]
    fn deserialize_i64_error_from_string_with_underscores() {
        let json = r#"{"val": "1_000_000"}"#;
        // std::primitive::i64.from_str() does not support underscores
        assert!(serde_json::from_str::<TestI64>(json).is_err(), "String with underscores should fail parsing to i64");
    }

    #[test]
    fn deserialize_i64_from_string_with_leading_zeros() {
        let json = r#"{"val": "000123"}"#;
        let expected = TestI64 { val: 123 };
        // std::primitive::i64.from_str() supports leading zeros
        assert_eq!(serde_json::from_str::<TestI64>(json).unwrap(), expected, "String with leading zeros should parse");
    }

    #[test]
    fn deserialize_i64_from_string_with_leading_zeros_negative() {
        let json = r#"{"val": "-000123"}"#;
        let expected = TestI64 { val: -123 };
        assert_eq!(serde_json::from_str::<TestI64>(json).unwrap(), expected, "Negative string with leading zeros should parse");
    }
    
    #[test]
    fn deserialize_i64_error_from_string_with_decimal_zeros() {
        let json = r#"{"val": "123.000"}"#;
        // std::primitive::i64.from_str() does not support decimals
        assert!(serde_json::from_str::<TestI64>(json).is_err(), "String with decimal part should fail parsing to i64");
    }

    #[test]
    fn deserialize_i64_error_from_string_with_internal_decimal() {
        let json = r#"{"val": "12.345"}"#;
        assert!(serde_json::from_str::<TestI64>(json).is_err(), "String with internal decimal point should fail");
    }

    #[test]
    fn deserialize_i64_error_from_localized_string_commas() {
        let json = r#"{"val": "1,234"}"#;
        // std::primitive::i64.from_str() does not support commas
        assert!(serde_json::from_str::<TestI64>(json).is_err(), "Localized string with commas should fail parsing to i64");
    }

    // --- u64 Deserialization Tests ---
    #[test]
    fn deserialize_u64_from_json_number() {
        let json = r#"{"val": 123}"#;
        let expected = TestU64 { val: 123 };
        assert_eq!(serde_json::from_str::<TestU64>(json).unwrap(), expected);
    }
    
    #[test]
    fn deserialize_u64_from_json_number_zero() {
        let json = r#"{"val": 0}"#;
        let expected = TestU64 { val: 0 };
        assert_eq!(serde_json::from_str::<TestU64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_u64_from_json_number_max() {
        let json = format!(r#"{{"val": {}}}"#, u64::MAX);
        let expected = TestU64 { val: u64::MAX };
        assert_eq!(serde_json::from_str::<TestU64>(&json).unwrap(), expected);
    }

    #[test]
    fn deserialize_u64_from_json_string() {
        let json = r#"{"val": "789"}"#;
        let expected = TestU64 { val: 789 };
        assert_eq!(serde_json::from_str::<TestU64>(json).unwrap(), expected);
    }
    
    #[test]
    fn deserialize_u64_from_json_string_zero() {
        let json = r#"{"val": "0"}"#;
        let expected = TestU64 { val: 0 };
        assert_eq!(serde_json::from_str::<TestU64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_u64_from_json_string_max() {
        let json = format!(r#"{{"val": "{}"}}"#, u64::MAX);
        let expected = TestU64 { val: u64::MAX };
        assert_eq!(serde_json::from_str::<TestU64>(&json).unwrap(), expected);
    }

    #[test]
    fn deserialize_u64_from_json_string_with_plus_prefix() {
        let json = r#"{"val": "+123"}"#;
        let expected = TestU64 { val: 123 };
        assert_eq!(serde_json::from_str::<TestU64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_u64_from_json_string_with_plus_zero() {
        let json = r#"{"val": "+0"}"#;
        let expected = TestU64 { val: 0 };
        assert_eq!(serde_json::from_str::<TestU64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_u64_error_from_json_string_with_leading_whitespace() {
        let json = r#"{"val": " 123"}"#;
        assert!(serde_json::from_str::<TestU64>(json).is_err());
    }

    #[test]
    fn deserialize_u64_error_from_json_string_with_trailing_whitespace() {
        let json = r#"{"val": "123 "}"#;
        assert!(serde_json::from_str::<TestU64>(json).is_err());
    }

    #[test]
    fn deserialize_u64_error_from_json_string_with_invalid_plus_prefix() {
        let json = r#"{"val": "++123"}"#;
        assert!(serde_json::from_str::<TestU64>(json).is_err());
    }

    #[test]
    fn deserialize_u64_error_from_string_negative() {
        let json = r#"{"val": "-123"}"#; // Negative not allowed for u64 string parse
        assert!(serde_json::from_str::<TestU64>(json).is_err());
    }

    #[test]
    fn deserialize_u64_error_from_json_number_negative() {
        let json = r#"{"val": -1}"#; // Negative not allowed for u64
        let err = serde_json::from_str::<TestU64>(json).unwrap_err();
        // Check for TryFrom conversion error, the exact message may vary by serde version
        assert!(err.to_string().contains("out of range") || 
                err.to_string().contains("negative integer") ||
                err.to_string().contains("invalid value"));
    }
    
    #[test]
    fn deserialize_u64_error_from_string_not_a_number() {
        let json = r#"{"val": "abc"}"#;
        assert!(serde_json::from_str::<TestU64>(json).is_err());
    }

    #[test]
    fn deserialize_u64_error_from_string_float() {
        let json = r#"{"val": "123.45"}"#;
        assert!(serde_json::from_str::<TestU64>(json).is_err());
    }

    #[test]
    fn deserialize_u64_error_from_string_empty() {
        let json = r#"{"val": ""}"#;
        assert!(serde_json::from_str::<TestU64>(json).is_err());
    }

    #[test]
    fn deserialize_u64_error_from_string_overflow() {
        let overflow_val = (u64::MAX as u128) + 1;
        let json = format!(r#"{{"val": "{}"}}"#, overflow_val);
        assert!(serde_json::from_str::<TestU64>(&json).is_err());
    }

    #[test]
    fn deserialize_u64_error_from_json_float_number() {
        let json = r#"{"val": 123.45}"#;
        let err = serde_json::from_str::<TestU64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid type: floating point"));
    }

    #[test]
    fn deserialize_u64_error_from_json_bool_true() {
        let json = r#"{"val": true}"#;
        let err = serde_json::from_str::<TestU64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid type: boolean `true`"));
    }

    #[test]
    fn deserialize_u64_error_from_json_array() {
        let json = r#"{"val": []}"#;
        let err = serde_json::from_str::<TestU64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid type: sequence"));
    }

    #[test]
    fn deserialize_u64_error_from_json_object() {
        let json = r#"{"val": {}}"#;
        let err = serde_json::from_str::<TestU64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid type: map"));
    }

    #[test]
    fn deserialize_u64_error_from_json_null() {
        let json = r#"{"val": null}"#;
        let err = serde_json::from_str::<TestU64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid type: null"));
    }

    // -- Additional u64 String Format Tests --
    #[test]
    fn deserialize_u64_error_from_hex_string() {
        let json = r#"{"val": "0x1A"}"#; // Hex "26"
        assert!(serde_json::from_str::<TestU64>(json).is_err(), "Hex string should fail parsing to u64");
    }

    #[test]
    fn deserialize_u64_error_from_octal_string() {
        let json = r#"{"val": "0o77"}"#; // Octal "63"
        assert!(serde_json::from_str::<TestU64>(json).is_err(), "Octal string should fail parsing to u64");
    }

    #[test]
    fn deserialize_u64_error_from_scientific_notation_string() {
        let json = r#"{"val": "1e3"}"#;
        assert!(serde_json::from_str::<TestU64>(json).is_err(), "Scientific notation string should fail parsing to u64");
    }

    #[test]
    fn deserialize_u64_error_from_string_with_underscores() {
        let json = r#"{"val": "1_000_000"}"#;
        assert!(serde_json::from_str::<TestU64>(json).is_err(), "String with underscores should fail parsing to u64");
    }

    #[test]
    fn deserialize_u64_from_string_with_leading_zeros() {
        let json = r#"{"val": "000123"}"#;
        let expected = TestU64 { val: 123 };
        assert_eq!(serde_json::from_str::<TestU64>(json).unwrap(), expected, "String with leading zeros should parse to u64");
    }

    #[test]
    fn deserialize_u64_error_from_string_with_decimal_zeros() {
        let json = r#"{"val": "123.000"}"#;
        assert!(serde_json::from_str::<TestU64>(json).is_err(), "String with decimal part should fail parsing to u64");
    }

    #[test]
    fn deserialize_u64_error_from_localized_string_commas() {
        let json = r#"{"val": "1,234"}"#;
        assert!(serde_json::from_str::<TestU64>(json).is_err(), "Localized string with commas should fail parsing to u64");
    }

    // --- i64 Serialization Tests ---
    #[test]
    fn serialize_i64_positive() {
        let data = TestI64 { val: 123 };
        let expected_json = r#"{"val":"123"}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    #[test]
    fn serialize_i64_negative() {
        let data = TestI64 { val: -456 };
        let expected_json = r#"{"val":"-456"}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    #[test]
    fn serialize_i64_zero() {
        let data = TestI64 { val: 0 };
        let expected_json = r#"{"val":"0"}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }
    
    #[test]
    fn serialize_i64_max() {
        let data = TestI64 { val: i64::MAX };
        let expected_json = format!(r#"{{"val":"{}"}}"#, i64::MAX);
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    #[test]
    fn serialize_i64_min() {
        let data = TestI64 { val: i64::MIN };
        let expected_json = format!(r#"{{"val":"{}"}}"#, i64::MIN);
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }


    // --- u64 Serialization Tests ---
    #[test]
    fn serialize_u64_positive() {
        let data = TestU64 { val: 789 };
        let expected_json = r#"{"val":"789"}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    #[test]
    fn serialize_u64_zero() {
        let data = TestU64 { val: 0 };
        let expected_json = r#"{"val":"0"}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }
    
    #[test]
    fn serialize_u64_max() {
        let data = TestU64 { val: u64::MAX };
        let expected_json = format!(r#"{{"val":"{}"}}"#, u64::MAX);
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    // --- Option<i64> Tests ---
    #[test]
    fn deserialize_option_i64_some_from_json_number() {
        let json = r#"{"val": 123}"#;
        let expected = TestOptionI64 { val: Some(123) };
        assert_eq!(serde_json::from_str::<TestOptionI64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_option_i64_some_from_json_string() {
        let json = r#"{"val": "456"}"#;
        let expected = TestOptionI64 { val: Some(456) };
        assert_eq!(serde_json::from_str::<TestOptionI64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_option_i64_none_from_json_null() {
        let json = r#"{"val": null}"#;
        let expected = TestOptionI64 { val: None };
        assert_eq!(serde_json::from_str::<TestOptionI64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_option_i64_error_from_invalid_string() {
        let json = r#"{"val": "abc"}"#;
        assert!(serde_json::from_str::<TestOptionI64>(json).is_err());
    }

    #[test]
    fn deserialize_option_i64_error_from_invalid_type() {
        let json = r#"{"val": true}"#;
        let err = serde_json::from_str::<TestOptionI64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid type: boolean `true`"));
    }
    
    #[test]
    fn serialize_option_i64_some() {
        let data = TestOptionI64 { val: Some(123) };
        let expected_json = r#"{"val":"123"}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    #[test]
    fn serialize_option_i64_none() {
        let data = TestOptionI64 { val: None };
        let expected_json = r#"{"val":null}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    // --- Option<u64> Tests ---
    #[test]
    fn deserialize_option_u64_some_from_json_number() {
        let json = r#"{"val": 123}"#;
        let expected = TestOptionU64 { val: Some(123) };
        assert_eq!(serde_json::from_str::<TestOptionU64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_option_u64_some_from_json_string() {
        let json = r#"{"val": "456"}"#;
        let expected = TestOptionU64 { val: Some(456) };
        assert_eq!(serde_json::from_str::<TestOptionU64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_option_u64_none_from_json_null() {
        let json = r#"{"val": null}"#;
        let expected = TestOptionU64 { val: None };
        assert_eq!(serde_json::from_str::<TestOptionU64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_option_u64_error_from_invalid_string() {
        let json = r#"{"val": "abc"}"#;
        assert!(serde_json::from_str::<TestOptionU64>(json).is_err());
    }
    
    #[test]
    fn deserialize_option_u64_error_from_negative_string() {
        let json = r#"{"val": "-1"}"#; // Invalid for u64
        assert!(serde_json::from_str::<TestOptionU64>(json).is_err());
    }

    #[test]
    fn serialize_option_u64_some() {
        let data = TestOptionU64 { val: Some(123) };
        let expected_json = r#"{"val":"123"}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    #[test]
    fn serialize_option_u64_none() {
        let data = TestOptionU64 { val: None };
        let expected_json = r#"{"val":null}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    // --- Vec<i64> Tests ---
    #[test]
    fn deserialize_vec_i64_empty() {
        let json = r#"{"val": []}"#;
        let expected = TestVecI64 { val: vec![] };
        assert_eq!(serde_json::from_str::<TestVecI64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_vec_i64_from_numbers_and_strings() {
        let json = r#"{"val": [1, "2", -3, "-4"]}"#;
        let expected = TestVecI64 { val: vec![1, 2, -3, -4] };
        assert_eq!(serde_json::from_str::<TestVecI64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_vec_i64_error_if_item_is_invalid_string() {
        let json = r#"{"val": [1, "abc", 3]}"#;
        let err = serde_json::from_str::<TestVecI64>(json).unwrap_err();
        // The error will point to the specific failing element
        assert!(err.to_string().contains("invalid digit found in string")); // From parse error
    }

    #[test]
    fn deserialize_vec_i64_error_if_item_is_invalid_type() {
        let json = r#"{"val": [1, true, 3]}"#;
        let err = serde_json::from_str::<TestVecI64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid type: boolean `true`"));
    }

    #[test]
    fn serialize_vec_i64_empty() {
        let data = TestVecI64 { val: vec![] };
        let expected_json = r#"{"val":[]}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    #[test]
    fn serialize_vec_i64_with_values() {
        let data = TestVecI64 { val: vec![1, -2, 0] };
        let expected_json = r#"{"val":["1","-2","0"]}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    // --- Vec<u64> Tests ---
    #[test]
    fn deserialize_vec_u64_empty() {
        let json = r#"{"val": []}"#;
        let expected = TestVecU64 { val: vec![] };
        assert_eq!(serde_json::from_str::<TestVecU64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_vec_u64_from_numbers_and_strings() {
        let json = r#"{"val": [1, "2", 3, "4"]}"#;
        let expected = TestVecU64 { val: vec![1, 2, 3, 4] };
        assert_eq!(serde_json::from_str::<TestVecU64>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_vec_u64_error_if_item_is_invalid_string() {
        let json = r#"{"val": [1, "abc", 3]}"#;
        let err = serde_json::from_str::<TestVecU64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid digit found in string"));
    }

    #[test]
    fn deserialize_vec_u64_error_if_item_is_negative_string() {
        let json = r#"{"val": [1, "-2", 3]}"#;
        let err = serde_json::from_str::<TestVecU64>(json).unwrap_err();
        assert!(err.to_string().contains("invalid digit found in string")); // u64 parse error
    }
    
    #[test]
    fn deserialize_vec_u64_error_if_item_is_negative_number() {
        let json = r#"{"val": [1, -2, 3]}"#;
        let err = serde_json::from_str::<TestVecU64>(json).unwrap_err();
        // Check for TryFrom conversion error, the exact message may vary by serde version
        assert!(err.to_string().contains("out of range") || 
                err.to_string().contains("negative integer") ||
                err.to_string().contains("invalid value")); // try_into error
    }

    #[test]
    fn serialize_vec_u64_empty() {
        let data = TestVecU64 { val: vec![] };
        let expected_json = r#"{"val":[]}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    #[test]
    fn serialize_vec_u64_with_values() {
        let data = TestVecU64 { val: vec![1, 2, 0] };
        let expected_json = r#"{"val":["1","2","0"]}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    // --- Enum with NumberOrString field Tests ---
    #[test]
    fn deserialize_enum_variant_a_with_number() {
        let json = r#"{"variantA": {"numVal": 123, "otherData": "test"}}"#;
        let expected = TestEnum::VariantA { num_val: 123, other_data: "test".to_string() };
        assert_eq!(serde_json::from_str::<TestEnum>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_enum_variant_a_with_string_number() {
        let json = r#"{"variantA": {"numVal": "-45", "otherData": "data"}}"#;
        let expected = TestEnum::VariantA { num_val: -45, other_data: "data".to_string() };
        assert_eq!(serde_json::from_str::<TestEnum>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_enum_variant_b_with_number() {
        let json = r#"{"variantB": {"count": 7890}}"#;
        let expected = TestEnum::VariantB { count: 7890 };
        assert_eq!(serde_json::from_str::<TestEnum>(json).unwrap(), expected);
    }

    #[test]
    fn deserialize_enum_variant_b_with_string_number() {
        let json = r#"{"variantB": {"count": "1234567890"}}"#;
        let expected = TestEnum::VariantB { count: 1234567890 };
        assert_eq!(serde_json::from_str::<TestEnum>(json).unwrap(), expected);
    }
    
    #[test]
    fn deserialize_enum_variant_a_error_invalid_num_string() {
        let json = r#"{"variantA": {"numVal": "abc", "otherData": "test"}}"#;
        assert!(serde_json::from_str::<TestEnum>(json).is_err());
    }

    #[test]
    fn serialize_enum_variant_a() {
        let data = TestEnum::VariantA { num_val: 123, other_data: "test".to_string() };
        // Note: num_val will be serialized as a string by NumberOrString
        let expected_json = r#"{"variantA":{"numVal":"123","otherData":"test"}}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }

    #[test]
    fn serialize_enum_variant_b() {
        let data = TestEnum::VariantB { count: 7890 };
        let expected_json = r#"{"variantB":{"count":"7890"}}"#;
        assert_eq!(serde_json::to_string(&data).unwrap(), expected_json);
    }
}

/// Uint512 is an XDR Typedef defines as:
///
/// ```text
/// typedef opaque uint512[64];
/// ```
///
#[cfg_eval::cfg_eval]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde_with::SerializeDisplay, serde_with::DeserializeFromStr))]
pub struct Uint512(
  pub [u8; 64]
);

impl core::fmt::Debug for Uint512 {
  fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
      let v = &self.0;
      write!(f, "Uint512(")?;
      for b in v {
          write!(f, "{b:02x}")?;
      }
      write!(f, ")")?;
      Ok(())
  }
}
impl core::fmt::Display for Uint512 {
  fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
      let v = &self.0;
      for b in v {
          write!(f, "{b:02x}")?;
      }
      Ok(())
  }
}

#[cfg(feature = "alloc")]
impl core::str::FromStr for Uint512 {
  type Err = Error;
  fn from_str(s: &str) -> core::result::Result<Self, Self::Err> {
      hex::decode(s).map_err(|_| Error::InvalidHex)?.try_into()
  }
}
#[cfg(feature = "schemars")]
impl schemars::JsonSchema for Uint512 {
    fn schema_name() -> String {
        "Uint512".to_string()
    }

    fn is_referenceable() -> bool {
        false
    }

    fn json_schema(gen: &mut schemars::gen::SchemaGenerator) -> schemars::schema::Schema {
        let schema = String::json_schema(gen);
        if let schemars::schema::Schema::Object(mut schema) = schema {
            schema.extensions.insert(
                "contentEncoding".to_owned(),
                serde_json::Value::String("hex".to_string()),
            );
            schema.extensions.insert(
                "contentMediaType".to_owned(),
                serde_json::Value::String("application/binary".to_string()),
            );
            let string = *schema.string.unwrap_or_default().clone();
            schema.string = Some(Box::new(schemars::schema::StringValidation {
                max_length: 64_u32.checked_mul(2).map(Some).unwrap_or_default(),
                min_length: 64_u32.checked_mul(2).map(Some).unwrap_or_default(),
                ..string
            }));
            schema.into()
        } else {
            schema
        }
    }
}
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
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let i = <[u8; 64]>::read_xdr(r)?;
            let v = Uint512(i);
            Ok(v)
        })
    }
}

impl WriteXdr for Uint512 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w|{ self.0.write_xdr(w) })
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
    fn try_from(x: Vec<u8>) -> Result<Self, Error> {
        x.as_slice().try_into()
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<u8>> for Uint512 {
    type Error = Error;
    fn try_from(x: &Vec<u8>) -> Result<Self, Error> {
        x.as_slice().try_into()
    }
}

impl TryFrom<&[u8]> for Uint512 {
    type Error = Error;
    fn try_from(x: &[u8]) -> Result<Self, Error> {
        Ok(Uint512(x.try_into()?))
    }
}

impl AsRef<[u8]> for Uint512 {
    #[must_use]
    fn as_ref(&self) -> &[u8] {
        &self.0
    }
}

/// Uint513 is an XDR Typedef defines as:
///
/// ```text
/// typedef opaque uint513<64>;
/// ```
///
#[cfg_eval::cfg_eval]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[derive(Default)]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[derive(Debug)]
pub struct Uint513(
  pub BytesM::<64>
);

impl From<Uint513> for BytesM::<64> {
    #[must_use]
    fn from(x: Uint513) -> Self {
        x.0
    }
}

impl From<BytesM::<64>> for Uint513 {
    #[must_use]
    fn from(x: BytesM::<64>) -> Self {
        Uint513(x)
    }
}

impl AsRef<BytesM::<64>> for Uint513 {
    #[must_use]
    fn as_ref(&self) -> &BytesM::<64> {
        &self.0
    }
}

impl ReadXdr for Uint513 {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let i = BytesM::<64>::read_xdr(r)?;
            let v = Uint513(i);
            Ok(v)
        })
    }
}

impl WriteXdr for Uint513 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w|{ self.0.write_xdr(w) })
    }
}

impl Deref for Uint513 {
  type Target = BytesM::<64>;
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
    fn try_from(x: Vec<u8>) -> Result<Self, Error> {
        Ok(Uint513(x.try_into()?))
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<u8>> for Uint513 {
    type Error = Error;
    fn try_from(x: &Vec<u8>) -> Result<Self, Error> {
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

/// Uint514 is an XDR Typedef defines as:
///
/// ```text
/// typedef opaque uint514<>;
/// ```
///
#[cfg_eval::cfg_eval]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[derive(Default)]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[derive(Debug)]
pub struct Uint514(
  pub BytesM
);

impl From<Uint514> for BytesM {
    #[must_use]
    fn from(x: Uint514) -> Self {
        x.0
    }
}

impl From<BytesM> for Uint514 {
    #[must_use]
    fn from(x: BytesM) -> Self {
        Uint514(x)
    }
}

impl AsRef<BytesM> for Uint514 {
    #[must_use]
    fn as_ref(&self) -> &BytesM {
        &self.0
    }
}

impl ReadXdr for Uint514 {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let i = BytesM::read_xdr(r)?;
            let v = Uint514(i);
            Ok(v)
        })
    }
}

impl WriteXdr for Uint514 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w|{ self.0.write_xdr(w) })
    }
}

impl Deref for Uint514 {
  type Target = BytesM;
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
    fn try_from(x: Vec<u8>) -> Result<Self, Error> {
        Ok(Uint514(x.try_into()?))
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<u8>> for Uint514 {
    type Error = Error;
    fn try_from(x: &Vec<u8>) -> Result<Self, Error> {
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

/// Str is an XDR Typedef defines as:
///
/// ```text
/// typedef string str<64>;
/// ```
///
#[cfg_eval::cfg_eval]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[derive(Default)]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[derive(Debug)]
pub struct Str(
  pub StringM::<64>
);

impl From<Str> for StringM::<64> {
    #[must_use]
    fn from(x: Str) -> Self {
        x.0
    }
}

impl From<StringM::<64>> for Str {
    #[must_use]
    fn from(x: StringM::<64>) -> Self {
        Str(x)
    }
}

impl AsRef<StringM::<64>> for Str {
    #[must_use]
    fn as_ref(&self) -> &StringM::<64> {
        &self.0
    }
}

impl ReadXdr for Str {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let i = StringM::<64>::read_xdr(r)?;
            let v = Str(i);
            Ok(v)
        })
    }
}

impl WriteXdr for Str {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w|{ self.0.write_xdr(w) })
    }
}

impl Deref for Str {
  type Target = StringM::<64>;
  fn deref(&self) -> &Self::Target {
      &self.0
  }
}

impl From<Str> for Vec<u8> {
    #[must_use]
    fn from(x: Str) -> Self {
        x.0.0
    }
}

impl TryFrom<Vec<u8>> for Str {
    type Error = Error;
    fn try_from(x: Vec<u8>) -> Result<Self, Error> {
        Ok(Str(x.try_into()?))
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<u8>> for Str {
    type Error = Error;
    fn try_from(x: &Vec<u8>) -> Result<Self, Error> {
        Ok(Str(x.try_into()?))
    }
}

impl AsRef<Vec<u8>> for Str {
    #[must_use]
    fn as_ref(&self) -> &Vec<u8> {
        &self.0.0
    }
}

impl AsRef<[u8]> for Str {
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

/// Str2 is an XDR Typedef defines as:
///
/// ```text
/// typedef string str2<>;
/// ```
///
#[cfg_eval::cfg_eval]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[derive(Default)]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[derive(Debug)]
pub struct Str2(
  pub StringM
);

impl From<Str2> for StringM {
    #[must_use]
    fn from(x: Str2) -> Self {
        x.0
    }
}

impl From<StringM> for Str2 {
    #[must_use]
    fn from(x: StringM) -> Self {
        Str2(x)
    }
}

impl AsRef<StringM> for Str2 {
    #[must_use]
    fn as_ref(&self) -> &StringM {
        &self.0
    }
}

impl ReadXdr for Str2 {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let i = StringM::read_xdr(r)?;
            let v = Str2(i);
            Ok(v)
        })
    }
}

impl WriteXdr for Str2 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w|{ self.0.write_xdr(w) })
    }
}

impl Deref for Str2 {
  type Target = StringM;
  fn deref(&self) -> &Self::Target {
      &self.0
  }
}

impl From<Str2> for Vec<u8> {
    #[must_use]
    fn from(x: Str2) -> Self {
        x.0.0
    }
}

impl TryFrom<Vec<u8>> for Str2 {
    type Error = Error;
    fn try_from(x: Vec<u8>) -> Result<Self, Error> {
        Ok(Str2(x.try_into()?))
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<u8>> for Str2 {
    type Error = Error;
    fn try_from(x: &Vec<u8>) -> Result<Self, Error> {
        Ok(Str2(x.try_into()?))
    }
}

impl AsRef<Vec<u8>> for Str2 {
    #[must_use]
    fn as_ref(&self) -> &Vec<u8> {
        &self.0.0
    }
}

impl AsRef<[u8]> for Str2 {
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

/// Hash is an XDR Typedef defines as:
///
/// ```text
/// typedef opaque Hash[32];
/// ```
///
#[cfg_eval::cfg_eval]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde_with::SerializeDisplay, serde_with::DeserializeFromStr))]
pub struct Hash(
  pub [u8; 32]
);

impl core::fmt::Debug for Hash {
  fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
      let v = &self.0;
      write!(f, "Hash(")?;
      for b in v {
          write!(f, "{b:02x}")?;
      }
      write!(f, ")")?;
      Ok(())
  }
}
impl core::fmt::Display for Hash {
  fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
      let v = &self.0;
      for b in v {
          write!(f, "{b:02x}")?;
      }
      Ok(())
  }
}

#[cfg(feature = "alloc")]
impl core::str::FromStr for Hash {
  type Err = Error;
  fn from_str(s: &str) -> core::result::Result<Self, Self::Err> {
      hex::decode(s).map_err(|_| Error::InvalidHex)?.try_into()
  }
}
#[cfg(feature = "schemars")]
impl schemars::JsonSchema for Hash {
    fn schema_name() -> String {
        "Hash".to_string()
    }

    fn is_referenceable() -> bool {
        false
    }

    fn json_schema(gen: &mut schemars::gen::SchemaGenerator) -> schemars::schema::Schema {
        let schema = String::json_schema(gen);
        if let schemars::schema::Schema::Object(mut schema) = schema {
            schema.extensions.insert(
                "contentEncoding".to_owned(),
                serde_json::Value::String("hex".to_string()),
            );
            schema.extensions.insert(
                "contentMediaType".to_owned(),
                serde_json::Value::String("application/binary".to_string()),
            );
            let string = *schema.string.unwrap_or_default().clone();
            schema.string = Some(Box::new(schemars::schema::StringValidation {
                max_length: 32_u32.checked_mul(2).map(Some).unwrap_or_default(),
                min_length: 32_u32.checked_mul(2).map(Some).unwrap_or_default(),
                ..string
            }));
            schema.into()
        } else {
            schema
        }
    }
}
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
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let i = <[u8; 32]>::read_xdr(r)?;
            let v = Hash(i);
            Ok(v)
        })
    }
}

impl WriteXdr for Hash {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w|{ self.0.write_xdr(w) })
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
    fn try_from(x: Vec<u8>) -> Result<Self, Error> {
        x.as_slice().try_into()
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<u8>> for Hash {
    type Error = Error;
    fn try_from(x: &Vec<u8>) -> Result<Self, Error> {
        x.as_slice().try_into()
    }
}

impl TryFrom<&[u8]> for Hash {
    type Error = Error;
    fn try_from(x: &[u8]) -> Result<Self, Error> {
        Ok(Hash(x.try_into()?))
    }
}

impl AsRef<[u8]> for Hash {
    #[must_use]
    fn as_ref(&self) -> &[u8] {
        &self.0
    }
}

/// Hashes1 is an XDR Typedef defines as:
///
/// ```text
/// typedef Hash Hashes1[12];
/// ```
///
#[cfg_eval::cfg_eval]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[derive(Debug)]
pub struct Hashes1(
  pub [Hash; 12]
);

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
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let i = <[Hash; 12]>::read_xdr(r)?;
            let v = Hashes1(i);
            Ok(v)
        })
    }
}

impl WriteXdr for Hashes1 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w|{ self.0.write_xdr(w) })
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
    fn try_from(x: Vec<Hash>) -> Result<Self, Error> {
        x.as_slice().try_into()
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<Hash>> for Hashes1 {
    type Error = Error;
    fn try_from(x: &Vec<Hash>) -> Result<Self, Error> {
        x.as_slice().try_into()
    }
}

impl TryFrom<&[Hash]> for Hashes1 {
    type Error = Error;
    fn try_from(x: &[Hash]) -> Result<Self, Error> {
        Ok(Hashes1(x.try_into()?))
    }
}

impl AsRef<[Hash]> for Hashes1 {
    #[must_use]
    fn as_ref(&self) -> &[Hash] {
        &self.0
    }
}

/// Hashes2 is an XDR Typedef defines as:
///
/// ```text
/// typedef Hash Hashes2<12>;
/// ```
///
#[cfg_eval::cfg_eval]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[derive(Default)]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[derive(Debug)]
pub struct Hashes2(
  pub VecM<Hash, 12>
);

impl From<Hashes2> for VecM<Hash, 12> {
    #[must_use]
    fn from(x: Hashes2) -> Self {
        x.0
    }
}

impl From<VecM<Hash, 12>> for Hashes2 {
    #[must_use]
    fn from(x: VecM<Hash, 12>) -> Self {
        Hashes2(x)
    }
}

impl AsRef<VecM<Hash, 12>> for Hashes2 {
    #[must_use]
    fn as_ref(&self) -> &VecM<Hash, 12> {
        &self.0
    }
}

impl ReadXdr for Hashes2 {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let i = VecM::<Hash, 12>::read_xdr(r)?;
            let v = Hashes2(i);
            Ok(v)
        })
    }
}

impl WriteXdr for Hashes2 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w|{ self.0.write_xdr(w) })
    }
}

impl Deref for Hashes2 {
  type Target = VecM<Hash, 12>;
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
    fn try_from(x: Vec<Hash>) -> Result<Self, Error> {
        Ok(Hashes2(x.try_into()?))
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<Hash>> for Hashes2 {
    type Error = Error;
    fn try_from(x: &Vec<Hash>) -> Result<Self, Error> {
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

/// Hashes3 is an XDR Typedef defines as:
///
/// ```text
/// typedef Hash Hashes3<>;
/// ```
///
#[cfg_eval::cfg_eval]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[derive(Default)]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[derive(Debug)]
pub struct Hashes3(
  pub VecM<Hash>
);

impl From<Hashes3> for VecM<Hash> {
    #[must_use]
    fn from(x: Hashes3) -> Self {
        x.0
    }
}

impl From<VecM<Hash>> for Hashes3 {
    #[must_use]
    fn from(x: VecM<Hash>) -> Self {
        Hashes3(x)
    }
}

impl AsRef<VecM<Hash>> for Hashes3 {
    #[must_use]
    fn as_ref(&self) -> &VecM<Hash> {
        &self.0
    }
}

impl ReadXdr for Hashes3 {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let i = VecM::<Hash>::read_xdr(r)?;
            let v = Hashes3(i);
            Ok(v)
        })
    }
}

impl WriteXdr for Hashes3 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w|{ self.0.write_xdr(w) })
    }
}

impl Deref for Hashes3 {
  type Target = VecM<Hash>;
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
    fn try_from(x: Vec<Hash>) -> Result<Self, Error> {
        Ok(Hashes3(x.try_into()?))
    }
}

#[cfg(feature = "alloc")]
impl TryFrom<&Vec<Hash>> for Hashes3 {
    type Error = Error;
    fn try_from(x: &Vec<Hash>) -> Result<Self, Error> {
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

/// OptHash1 is an XDR Typedef defines as:
///
/// ```text
/// typedef Hash *optHash1;
/// ```
///
#[cfg_eval::cfg_eval]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[derive(Debug)]
pub struct OptHash1(
  pub Option<Hash>
);

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
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let i = Option::<Hash>::read_xdr(r)?;
            let v = OptHash1(i);
            Ok(v)
        })
    }
}

impl WriteXdr for OptHash1 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w|{ self.0.write_xdr(w) })
    }
}

/// OptHash2 is an XDR Typedef defines as:
///
/// ```text
/// typedef Hash* optHash2;
/// ```
///
#[cfg_eval::cfg_eval]
#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[derive(Debug)]
pub struct OptHash2(
  pub Option<Hash>
);

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
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let i = Option::<Hash>::read_xdr(r)?;
            let v = OptHash2(i);
            Ok(v)
        })
    }
}

impl WriteXdr for OptHash2 {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w|{ self.0.write_xdr(w) })
    }
}

/// Int1 is an XDR Typedef defines as:
///
/// ```text
/// typedef int             int1;
/// ```
///
pub type Int1 = i32;

/// Int2 is an XDR Typedef defines as:
///
/// ```text
/// typedef hyper           int2;
/// ```
///
pub type Int2 = i64;

/// Int3 is an XDR Typedef defines as:
///
/// ```text
/// typedef unsigned int    int3;
/// ```
///
pub type Int3 = u32;

/// Int4 is an XDR Typedef defines as:
///
/// ```text
/// typedef unsigned hyper  int4;
/// ```
///
pub type Int4 = u64;

/// MyStruct is an XDR Struct defines as:
///
/// ```text
/// struct MyStruct
/// {
///     uint512 field1;
///     optHash1 field2;
///     int1 field3;
///     unsigned int field4;
///     float field5;
///     double field6;
///     bool field7;
/// };
/// ```
///
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_eval::cfg_eval]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
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
            fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
                r.with_limited_depth(|r| {
                    Ok(Self{
                      field1: Uint512::read_xdr(r)?,
field2: OptHash1::read_xdr(r)?,
field3: i32::read_xdr(r)?,
field4: u32::read_xdr(r)?,
field5: f32::read_xdr(r)?,
field6: f64::read_xdr(r)?,
field7: bool::read_xdr(r)?,
                    })
                })
            }
        }

        impl WriteXdr for MyStruct {
            #[cfg(feature = "std")]
            fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
                w.with_limited_depth(|w| {
                    self.field1.write_xdr(w)?;
self.field2.write_xdr(w)?;
self.field3.write_xdr(w)?;
self.field4.write_xdr(w)?;
self.field5.write_xdr(w)?;
self.field6.write_xdr(w)?;
self.field7.write_xdr(w)?;
                    Ok(())
                })
            }
        }

/// LotsOfMyStructs is an XDR Struct defines as:
///
/// ```text
/// struct LotsOfMyStructs
/// {
///     MyStruct members<>;
/// };
/// ```
///
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_eval::cfg_eval]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
pub struct LotsOfMyStructs {
  pub members: VecM<MyStruct>,
}

impl ReadXdr for LotsOfMyStructs {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            Ok(Self{
              members: VecM::<MyStruct>::read_xdr(r)?,
            })
        })
    }
}

impl WriteXdr for LotsOfMyStructs {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w| {
            self.members.write_xdr(w)?;
            Ok(())
        })
    }
}

/// HasStuff is an XDR Struct defines as:
///
/// ```text
/// struct HasStuff
/// {
///   LotsOfMyStructs data;
/// };
/// ```
///
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_eval::cfg_eval]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
pub struct HasStuff {
  pub data: LotsOfMyStructs,
}

impl ReadXdr for HasStuff {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            Ok(Self{
              data: LotsOfMyStructs::read_xdr(r)?,
            })
        })
    }
}

impl WriteXdr for HasStuff {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w| {
            self.data.write_xdr(w)?;
            Ok(())
        })
    }
}

/// Color is an XDR Enum defines as:
///
/// ```text
/// enum Color {
///   RED,
///   BLUE = 5,
///   GREEN
/// };
/// ```
///
// enum
#[derive(Clone, Copy, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[repr(i32)]
pub enum Color {
  Red = 0,
  Blue = 5,
  Green = 6,
}

        impl Color {
            pub const VARIANTS: [Color; 3] = [ Color::Red,
Color::Blue,
Color::Green, ];
            pub const VARIANTS_STR: [&'static str; 3] = [ "Red",
"Blue",
"Green", ];

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
                Self::VARIANTS
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
                Self::VARIANTS.iter()
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

            fn try_from(i: i32) -> Result<Self, Error> {
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
            fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
                r.with_limited_depth(|r| {
                    let e = i32::read_xdr(r)?;
                    let v: Self = e.try_into()?;
                    Ok(v)
                })
            }
        }

        impl WriteXdr for Color {
            #[cfg(feature = "std")]
            fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
                w.with_limited_depth(|w| {
                    let i: i32 = (*self).into();
                    i.write_xdr(w)
                })
            }
        }

/// Foo is an XDR Const defines as:
///
/// ```text
/// const FOO = 1244;
/// ```
///
pub const FOO: u64 = 1244;

/// Bar is an XDR Const defines as:
///
/// ```text
/// const BAR = FOO;
/// ```
///
pub const BAR: u64 = FOO;

/// NesterNestedEnum is an XDR NestedEnum defines as:
///
/// ```text
/// enum {
///     BLAH_1,
///     BLAH_2
///   }
/// ```
///
// enum
#[derive(Clone, Copy, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[repr(i32)]
pub enum NesterNestedEnum {
  B1 = 0,
  B2 = 1,
}

        impl NesterNestedEnum {
            pub const VARIANTS: [NesterNestedEnum; 2] = [ NesterNestedEnum::B1,
NesterNestedEnum::B2, ];
            pub const VARIANTS_STR: [&'static str; 2] = [ "B1",
"B2", ];

            #[must_use]
            pub const fn name(&self) -> &'static str {
                match self {
                    Self::B1 => "B1",
Self::B2 => "B2",
                }
            }

            #[must_use]
            pub const fn variants() -> [NesterNestedEnum; 2] {
                Self::VARIANTS
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
                Self::VARIANTS.iter()
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

            fn try_from(i: i32) -> Result<Self, Error> {
                let e = match i {
                    0 => NesterNestedEnum::B1,
1 => NesterNestedEnum::B2,
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
            fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
                r.with_limited_depth(|r| {
                    let e = i32::read_xdr(r)?;
                    let v: Self = e.try_into()?;
                    Ok(v)
                })
            }
        }

        impl WriteXdr for NesterNestedEnum {
            #[cfg(feature = "std")]
            fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
                w.with_limited_depth(|w| {
                    let i: i32 = (*self).into();
                    i.write_xdr(w)
                })
            }
        }

/// NesterNestedStruct is an XDR NestedStruct defines as:
///
/// ```text
/// struct {
///     int blah;
///   }
/// ```
///
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_eval::cfg_eval]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
pub struct NesterNestedStruct {
  pub blah: i32,
}

impl ReadXdr for NesterNestedStruct {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            Ok(Self{
              blah: i32::read_xdr(r)?,
            })
        })
    }
}

impl WriteXdr for NesterNestedStruct {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w| {
            self.blah.write_xdr(w)?;
            Ok(())
        })
    }
}

/// NesterNestedUnion is an XDR NestedUnion defines as:
///
/// ```text
/// union switch (Color color) {
///     case RED:
///       void;
///     default:
///       int blah2;
///   }
/// ```
///
// union with discriminant Color
#[cfg_eval::cfg_eval]
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[allow(clippy::large_enum_variant)]
pub enum NesterNestedUnion {
  Red,
}

impl NesterNestedUnion {
    pub const VARIANTS: [Color; 1] = [
        Color::Red,
    ];
    pub const VARIANTS_STR: [&'static str; 1] = [
        "Red",
    ];

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
        Self::VARIANTS
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
        Self::VARIANTS.iter()
    }
}

impl Union<Color> for NesterNestedUnion {}

impl ReadXdr for NesterNestedUnion {
    #[cfg(feature = "std")]
    fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
        r.with_limited_depth(|r| {
            let dv: Color = <Color as ReadXdr>::read_xdr(r)?;
            #[allow(clippy::match_same_arms, clippy::match_wildcard_for_single_variants)]
            let v = match dv {
                Color::Red => Self::Red,
                #[allow(unreachable_patterns)]
                _ => return Err(Error::Invalid),
            };
            Ok(v)
        })
    }
}

impl WriteXdr for NesterNestedUnion {
    #[cfg(feature = "std")]
    fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
        w.with_limited_depth(|w| {
            self.discriminant().write_xdr(w)?;
            #[allow(clippy::match_same_arms)]
            match self {
                Self::Red => ().write_xdr(w)?,
            };
            Ok(())
        })
    }
}

/// Nester is an XDR Struct defines as:
///
/// ```text
/// struct Nester
/// {
///   enum {
///     BLAH_1,
///     BLAH_2
///   } nestedEnum;
/// 
///   struct {
///     int blah;
///   } nestedStruct;
/// 
///   union switch (Color color) {
///     case RED:
///       void;
///     default:
///       int blah2;
///   } nestedUnion;
/// 
/// 
/// };
/// ```
///
#[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_eval::cfg_eval]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), serde_with::serde_as, derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
pub struct Nester {
  pub nested_enum: NesterNestedEnum,
  pub nested_struct: NesterNestedStruct,
  pub nested_union: NesterNestedUnion,
}

        impl ReadXdr for Nester {
            #[cfg(feature = "std")]
            fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
                r.with_limited_depth(|r| {
                    Ok(Self{
                      nested_enum: NesterNestedEnum::read_xdr(r)?,
nested_struct: NesterNestedStruct::read_xdr(r)?,
nested_union: NesterNestedUnion::read_xdr(r)?,
                    })
                })
            }
        }

        impl WriteXdr for Nester {
            #[cfg(feature = "std")]
            fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
                w.with_limited_depth(|w| {
                    self.nested_enum.write_xdr(w)?;
self.nested_struct.write_xdr(w)?;
self.nested_union.write_xdr(w)?;
                    Ok(())
                })
            }
        }

        #[derive(Clone, Copy, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
        #[cfg_attr(
          all(feature = "serde", feature = "alloc"),
          derive(serde::Serialize, serde::Deserialize),
          serde(rename_all = "snake_case")
        )]
        #[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
        pub enum TypeVariant {
            Uint512,
Uint513,
Uint514,
Str,
Str2,
Hash,
Hashes1,
Hashes2,
Hashes3,
OptHash1,
OptHash2,
Int1,
Int2,
Int3,
Int4,
MyStruct,
LotsOfMyStructs,
HasStuff,
Color,
Nester,
NesterNestedEnum,
NesterNestedStruct,
NesterNestedUnion,
        }

        impl TypeVariant {
            pub const VARIANTS: [TypeVariant; 23] = [ TypeVariant::Uint512,
TypeVariant::Uint513,
TypeVariant::Uint514,
TypeVariant::Str,
TypeVariant::Str2,
TypeVariant::Hash,
TypeVariant::Hashes1,
TypeVariant::Hashes2,
TypeVariant::Hashes3,
TypeVariant::OptHash1,
TypeVariant::OptHash2,
TypeVariant::Int1,
TypeVariant::Int2,
TypeVariant::Int3,
TypeVariant::Int4,
TypeVariant::MyStruct,
TypeVariant::LotsOfMyStructs,
TypeVariant::HasStuff,
TypeVariant::Color,
TypeVariant::Nester,
TypeVariant::NesterNestedEnum,
TypeVariant::NesterNestedStruct,
TypeVariant::NesterNestedUnion, ];
            pub const VARIANTS_STR: [&'static str; 23] = [ "Uint512",
"Uint513",
"Uint514",
"Str",
"Str2",
"Hash",
"Hashes1",
"Hashes2",
"Hashes3",
"OptHash1",
"OptHash2",
"Int1",
"Int2",
"Int3",
"Int4",
"MyStruct",
"LotsOfMyStructs",
"HasStuff",
"Color",
"Nester",
"NesterNestedEnum",
"NesterNestedStruct",
"NesterNestedUnion", ];

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn name(&self) -> &'static str {
                match self {
                    Self::Uint512 => "Uint512",
Self::Uint513 => "Uint513",
Self::Uint514 => "Uint514",
Self::Str => "Str",
Self::Str2 => "Str2",
Self::Hash => "Hash",
Self::Hashes1 => "Hashes1",
Self::Hashes2 => "Hashes2",
Self::Hashes3 => "Hashes3",
Self::OptHash1 => "OptHash1",
Self::OptHash2 => "OptHash2",
Self::Int1 => "Int1",
Self::Int2 => "Int2",
Self::Int3 => "Int3",
Self::Int4 => "Int4",
Self::MyStruct => "MyStruct",
Self::LotsOfMyStructs => "LotsOfMyStructs",
Self::HasStuff => "HasStuff",
Self::Color => "Color",
Self::Nester => "Nester",
Self::NesterNestedEnum => "NesterNestedEnum",
Self::NesterNestedStruct => "NesterNestedStruct",
Self::NesterNestedUnion => "NesterNestedUnion",
                }
            }

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn variants() -> [TypeVariant; 23] {
                Self::VARIANTS
            }

            #[cfg(feature = "schemars")]
            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub fn json_schema(&self, gen: schemars::gen::SchemaGenerator) -> schemars::schema::RootSchema {
                match self {
                    Self::Uint512 => gen.into_root_schema_for::<Uint512>(),
Self::Uint513 => gen.into_root_schema_for::<Uint513>(),
Self::Uint514 => gen.into_root_schema_for::<Uint514>(),
Self::Str => gen.into_root_schema_for::<Str>(),
Self::Str2 => gen.into_root_schema_for::<Str2>(),
Self::Hash => gen.into_root_schema_for::<Hash>(),
Self::Hashes1 => gen.into_root_schema_for::<Hashes1>(),
Self::Hashes2 => gen.into_root_schema_for::<Hashes2>(),
Self::Hashes3 => gen.into_root_schema_for::<Hashes3>(),
Self::OptHash1 => gen.into_root_schema_for::<OptHash1>(),
Self::OptHash2 => gen.into_root_schema_for::<OptHash2>(),
Self::Int1 => gen.into_root_schema_for::<Int1>(),
Self::Int2 => gen.into_root_schema_for::<Int2>(),
Self::Int3 => gen.into_root_schema_for::<Int3>(),
Self::Int4 => gen.into_root_schema_for::<Int4>(),
Self::MyStruct => gen.into_root_schema_for::<MyStruct>(),
Self::LotsOfMyStructs => gen.into_root_schema_for::<LotsOfMyStructs>(),
Self::HasStuff => gen.into_root_schema_for::<HasStuff>(),
Self::Color => gen.into_root_schema_for::<Color>(),
Self::Nester => gen.into_root_schema_for::<Nester>(),
Self::NesterNestedEnum => gen.into_root_schema_for::<NesterNestedEnum>(),
Self::NesterNestedStruct => gen.into_root_schema_for::<NesterNestedStruct>(),
Self::NesterNestedUnion => gen.into_root_schema_for::<NesterNestedUnion>(),
                }
            }
        }

        impl Name for TypeVariant {
            #[must_use]
            fn name(&self) -> &'static str {
                Self::name(self)
            }
        }

        impl Variants<TypeVariant> for TypeVariant {
            fn variants() -> slice::Iter<'static, TypeVariant> {
                Self::VARIANTS.iter()
            }
        }

        impl core::str::FromStr for TypeVariant {
            type Err = Error;
            #[allow(clippy::too_many_lines)]
            fn from_str(s: &str) -> Result<Self, Error> {
                match s {
                    "Uint512" => Ok(Self::Uint512),
"Uint513" => Ok(Self::Uint513),
"Uint514" => Ok(Self::Uint514),
"Str" => Ok(Self::Str),
"Str2" => Ok(Self::Str2),
"Hash" => Ok(Self::Hash),
"Hashes1" => Ok(Self::Hashes1),
"Hashes2" => Ok(Self::Hashes2),
"Hashes3" => Ok(Self::Hashes3),
"OptHash1" => Ok(Self::OptHash1),
"OptHash2" => Ok(Self::OptHash2),
"Int1" => Ok(Self::Int1),
"Int2" => Ok(Self::Int2),
"Int3" => Ok(Self::Int3),
"Int4" => Ok(Self::Int4),
"MyStruct" => Ok(Self::MyStruct),
"LotsOfMyStructs" => Ok(Self::LotsOfMyStructs),
"HasStuff" => Ok(Self::HasStuff),
"Color" => Ok(Self::Color),
"Nester" => Ok(Self::Nester),
"NesterNestedEnum" => Ok(Self::NesterNestedEnum),
"NesterNestedStruct" => Ok(Self::NesterNestedStruct),
"NesterNestedUnion" => Ok(Self::NesterNestedUnion),
                    _ => Err(Error::Invalid),
                }
            }
        }

        #[derive(Clone, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
        #[cfg_attr(
          all(feature = "serde", feature = "alloc"),
          derive(serde::Serialize, serde::Deserialize),
          serde(rename_all = "snake_case"),
          serde(untagged),
        )]
        #[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
        pub enum Type {
            Uint512(Box<Uint512>),
Uint513(Box<Uint513>),
Uint514(Box<Uint514>),
Str(Box<Str>),
Str2(Box<Str2>),
Hash(Box<Hash>),
Hashes1(Box<Hashes1>),
Hashes2(Box<Hashes2>),
Hashes3(Box<Hashes3>),
OptHash1(Box<OptHash1>),
OptHash2(Box<OptHash2>),
Int1(Box<Int1>),
Int2(Box<Int2>),
Int3(Box<Int3>),
Int4(Box<Int4>),
MyStruct(Box<MyStruct>),
LotsOfMyStructs(Box<LotsOfMyStructs>),
HasStuff(Box<HasStuff>),
Color(Box<Color>),
Nester(Box<Nester>),
NesterNestedEnum(Box<NesterNestedEnum>),
NesterNestedStruct(Box<NesterNestedStruct>),
NesterNestedUnion(Box<NesterNestedUnion>),
        }

        impl Type {
            pub const VARIANTS: [TypeVariant; 23] = [ TypeVariant::Uint512,
TypeVariant::Uint513,
TypeVariant::Uint514,
TypeVariant::Str,
TypeVariant::Str2,
TypeVariant::Hash,
TypeVariant::Hashes1,
TypeVariant::Hashes2,
TypeVariant::Hashes3,
TypeVariant::OptHash1,
TypeVariant::OptHash2,
TypeVariant::Int1,
TypeVariant::Int2,
TypeVariant::Int3,
TypeVariant::Int4,
TypeVariant::MyStruct,
TypeVariant::LotsOfMyStructs,
TypeVariant::HasStuff,
TypeVariant::Color,
TypeVariant::Nester,
TypeVariant::NesterNestedEnum,
TypeVariant::NesterNestedStruct,
TypeVariant::NesterNestedUnion, ];
            pub const VARIANTS_STR: [&'static str; 23] = [ "Uint512",
"Uint513",
"Uint514",
"Str",
"Str2",
"Hash",
"Hashes1",
"Hashes2",
"Hashes3",
"OptHash1",
"OptHash2",
"Int1",
"Int2",
"Int3",
"Int4",
"MyStruct",
"LotsOfMyStructs",
"HasStuff",
"Color",
"Nester",
"NesterNestedEnum",
"NesterNestedStruct",
"NesterNestedUnion", ];

            #[cfg(feature = "std")]
            #[allow(clippy::too_many_lines)]
            pub fn read_xdr<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Result<Self, Error> {
                match v {
                    TypeVariant::Uint512 => r.with_limited_depth(|r| Ok(Self::Uint512(Box::new(Uint512::read_xdr(r)?)))),
TypeVariant::Uint513 => r.with_limited_depth(|r| Ok(Self::Uint513(Box::new(Uint513::read_xdr(r)?)))),
TypeVariant::Uint514 => r.with_limited_depth(|r| Ok(Self::Uint514(Box::new(Uint514::read_xdr(r)?)))),
TypeVariant::Str => r.with_limited_depth(|r| Ok(Self::Str(Box::new(Str::read_xdr(r)?)))),
TypeVariant::Str2 => r.with_limited_depth(|r| Ok(Self::Str2(Box::new(Str2::read_xdr(r)?)))),
TypeVariant::Hash => r.with_limited_depth(|r| Ok(Self::Hash(Box::new(Hash::read_xdr(r)?)))),
TypeVariant::Hashes1 => r.with_limited_depth(|r| Ok(Self::Hashes1(Box::new(Hashes1::read_xdr(r)?)))),
TypeVariant::Hashes2 => r.with_limited_depth(|r| Ok(Self::Hashes2(Box::new(Hashes2::read_xdr(r)?)))),
TypeVariant::Hashes3 => r.with_limited_depth(|r| Ok(Self::Hashes3(Box::new(Hashes3::read_xdr(r)?)))),
TypeVariant::OptHash1 => r.with_limited_depth(|r| Ok(Self::OptHash1(Box::new(OptHash1::read_xdr(r)?)))),
TypeVariant::OptHash2 => r.with_limited_depth(|r| Ok(Self::OptHash2(Box::new(OptHash2::read_xdr(r)?)))),
TypeVariant::Int1 => r.with_limited_depth(|r| Ok(Self::Int1(Box::new(Int1::read_xdr(r)?)))),
TypeVariant::Int2 => r.with_limited_depth(|r| Ok(Self::Int2(Box::new(Int2::read_xdr(r)?)))),
TypeVariant::Int3 => r.with_limited_depth(|r| Ok(Self::Int3(Box::new(Int3::read_xdr(r)?)))),
TypeVariant::Int4 => r.with_limited_depth(|r| Ok(Self::Int4(Box::new(Int4::read_xdr(r)?)))),
TypeVariant::MyStruct => r.with_limited_depth(|r| Ok(Self::MyStruct(Box::new(MyStruct::read_xdr(r)?)))),
TypeVariant::LotsOfMyStructs => r.with_limited_depth(|r| Ok(Self::LotsOfMyStructs(Box::new(LotsOfMyStructs::read_xdr(r)?)))),
TypeVariant::HasStuff => r.with_limited_depth(|r| Ok(Self::HasStuff(Box::new(HasStuff::read_xdr(r)?)))),
TypeVariant::Color => r.with_limited_depth(|r| Ok(Self::Color(Box::new(Color::read_xdr(r)?)))),
TypeVariant::Nester => r.with_limited_depth(|r| Ok(Self::Nester(Box::new(Nester::read_xdr(r)?)))),
TypeVariant::NesterNestedEnum => r.with_limited_depth(|r| Ok(Self::NesterNestedEnum(Box::new(NesterNestedEnum::read_xdr(r)?)))),
TypeVariant::NesterNestedStruct => r.with_limited_depth(|r| Ok(Self::NesterNestedStruct(Box::new(NesterNestedStruct::read_xdr(r)?)))),
TypeVariant::NesterNestedUnion => r.with_limited_depth(|r| Ok(Self::NesterNestedUnion(Box::new(NesterNestedUnion::read_xdr(r)?)))),
                }
            }

            #[cfg(feature = "base64")]
            pub fn read_xdr_base64<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Result<Self, Error> {
                let mut dec = Limited::new(base64::read::DecoderReader::new(&mut r.inner, base64::STANDARD), r.limits.clone());
                let t = Self::read_xdr(v, &mut dec)?;
                Ok(t)
            }

            #[cfg(feature = "std")]
            pub fn read_xdr_to_end<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Result<Self, Error> {
                let s = Self::read_xdr(v, r)?;
                // Check that any further reads, such as this read of one byte, read no
                // data, indicating EOF. If a byte is read the data is invalid.
                if r.read(&mut [0u8; 1])? == 0 {
                    Ok(s)
                } else {
                    Err(Error::Invalid)
                }
            }

            #[cfg(feature = "base64")]
            pub fn read_xdr_base64_to_end<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Result<Self, Error> {
                let mut dec = Limited::new(base64::read::DecoderReader::new(&mut r.inner, base64::STANDARD), r.limits.clone());
                let t = Self::read_xdr_to_end(v, &mut dec)?;
                Ok(t)
            }

            #[cfg(feature = "std")]
            #[allow(clippy::too_many_lines)]
            pub fn read_xdr_iter<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Box<dyn Iterator<Item=Result<Self, Error>> + '_> {
                match v {
                    TypeVariant::Uint512 => Box::new(ReadXdrIter::<_, Uint512>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Uint512(Box::new(t))))),
TypeVariant::Uint513 => Box::new(ReadXdrIter::<_, Uint513>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Uint513(Box::new(t))))),
TypeVariant::Uint514 => Box::new(ReadXdrIter::<_, Uint514>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Uint514(Box::new(t))))),
TypeVariant::Str => Box::new(ReadXdrIter::<_, Str>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Str(Box::new(t))))),
TypeVariant::Str2 => Box::new(ReadXdrIter::<_, Str2>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Str2(Box::new(t))))),
TypeVariant::Hash => Box::new(ReadXdrIter::<_, Hash>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Hash(Box::new(t))))),
TypeVariant::Hashes1 => Box::new(ReadXdrIter::<_, Hashes1>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Hashes1(Box::new(t))))),
TypeVariant::Hashes2 => Box::new(ReadXdrIter::<_, Hashes2>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Hashes2(Box::new(t))))),
TypeVariant::Hashes3 => Box::new(ReadXdrIter::<_, Hashes3>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Hashes3(Box::new(t))))),
TypeVariant::OptHash1 => Box::new(ReadXdrIter::<_, OptHash1>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::OptHash1(Box::new(t))))),
TypeVariant::OptHash2 => Box::new(ReadXdrIter::<_, OptHash2>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::OptHash2(Box::new(t))))),
TypeVariant::Int1 => Box::new(ReadXdrIter::<_, Int1>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Int1(Box::new(t))))),
TypeVariant::Int2 => Box::new(ReadXdrIter::<_, Int2>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Int2(Box::new(t))))),
TypeVariant::Int3 => Box::new(ReadXdrIter::<_, Int3>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Int3(Box::new(t))))),
TypeVariant::Int4 => Box::new(ReadXdrIter::<_, Int4>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Int4(Box::new(t))))),
TypeVariant::MyStruct => Box::new(ReadXdrIter::<_, MyStruct>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::MyStruct(Box::new(t))))),
TypeVariant::LotsOfMyStructs => Box::new(ReadXdrIter::<_, LotsOfMyStructs>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::LotsOfMyStructs(Box::new(t))))),
TypeVariant::HasStuff => Box::new(ReadXdrIter::<_, HasStuff>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::HasStuff(Box::new(t))))),
TypeVariant::Color => Box::new(ReadXdrIter::<_, Color>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Color(Box::new(t))))),
TypeVariant::Nester => Box::new(ReadXdrIter::<_, Nester>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Nester(Box::new(t))))),
TypeVariant::NesterNestedEnum => Box::new(ReadXdrIter::<_, NesterNestedEnum>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::NesterNestedEnum(Box::new(t))))),
TypeVariant::NesterNestedStruct => Box::new(ReadXdrIter::<_, NesterNestedStruct>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::NesterNestedStruct(Box::new(t))))),
TypeVariant::NesterNestedUnion => Box::new(ReadXdrIter::<_, NesterNestedUnion>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::NesterNestedUnion(Box::new(t))))),
                }
            }

            #[cfg(feature = "std")]
            #[allow(clippy::too_many_lines)]
            pub fn read_xdr_framed_iter<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Box<dyn Iterator<Item=Result<Self, Error>> + '_> {
                match v {
                    TypeVariant::Uint512 => Box::new(ReadXdrIter::<_, Frame<Uint512>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Uint512(Box::new(t.0))))),
TypeVariant::Uint513 => Box::new(ReadXdrIter::<_, Frame<Uint513>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Uint513(Box::new(t.0))))),
TypeVariant::Uint514 => Box::new(ReadXdrIter::<_, Frame<Uint514>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Uint514(Box::new(t.0))))),
TypeVariant::Str => Box::new(ReadXdrIter::<_, Frame<Str>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Str(Box::new(t.0))))),
TypeVariant::Str2 => Box::new(ReadXdrIter::<_, Frame<Str2>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Str2(Box::new(t.0))))),
TypeVariant::Hash => Box::new(ReadXdrIter::<_, Frame<Hash>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Hash(Box::new(t.0))))),
TypeVariant::Hashes1 => Box::new(ReadXdrIter::<_, Frame<Hashes1>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Hashes1(Box::new(t.0))))),
TypeVariant::Hashes2 => Box::new(ReadXdrIter::<_, Frame<Hashes2>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Hashes2(Box::new(t.0))))),
TypeVariant::Hashes3 => Box::new(ReadXdrIter::<_, Frame<Hashes3>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Hashes3(Box::new(t.0))))),
TypeVariant::OptHash1 => Box::new(ReadXdrIter::<_, Frame<OptHash1>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::OptHash1(Box::new(t.0))))),
TypeVariant::OptHash2 => Box::new(ReadXdrIter::<_, Frame<OptHash2>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::OptHash2(Box::new(t.0))))),
TypeVariant::Int1 => Box::new(ReadXdrIter::<_, Frame<Int1>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Int1(Box::new(t.0))))),
TypeVariant::Int2 => Box::new(ReadXdrIter::<_, Frame<Int2>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Int2(Box::new(t.0))))),
TypeVariant::Int3 => Box::new(ReadXdrIter::<_, Frame<Int3>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Int3(Box::new(t.0))))),
TypeVariant::Int4 => Box::new(ReadXdrIter::<_, Frame<Int4>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Int4(Box::new(t.0))))),
TypeVariant::MyStruct => Box::new(ReadXdrIter::<_, Frame<MyStruct>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::MyStruct(Box::new(t.0))))),
TypeVariant::LotsOfMyStructs => Box::new(ReadXdrIter::<_, Frame<LotsOfMyStructs>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::LotsOfMyStructs(Box::new(t.0))))),
TypeVariant::HasStuff => Box::new(ReadXdrIter::<_, Frame<HasStuff>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::HasStuff(Box::new(t.0))))),
TypeVariant::Color => Box::new(ReadXdrIter::<_, Frame<Color>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Color(Box::new(t.0))))),
TypeVariant::Nester => Box::new(ReadXdrIter::<_, Frame<Nester>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Nester(Box::new(t.0))))),
TypeVariant::NesterNestedEnum => Box::new(ReadXdrIter::<_, Frame<NesterNestedEnum>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::NesterNestedEnum(Box::new(t.0))))),
TypeVariant::NesterNestedStruct => Box::new(ReadXdrIter::<_, Frame<NesterNestedStruct>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::NesterNestedStruct(Box::new(t.0))))),
TypeVariant::NesterNestedUnion => Box::new(ReadXdrIter::<_, Frame<NesterNestedUnion>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::NesterNestedUnion(Box::new(t.0))))),
                }
            }

            #[cfg(feature = "base64")]
            #[allow(clippy::too_many_lines)]
            pub fn read_xdr_base64_iter<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Box<dyn Iterator<Item=Result<Self, Error>> + '_> {
                let dec = base64::read::DecoderReader::new(&mut r.inner, base64::STANDARD);
                match v {
                    TypeVariant::Uint512 => Box::new(ReadXdrIter::<_, Uint512>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Uint512(Box::new(t))))),
TypeVariant::Uint513 => Box::new(ReadXdrIter::<_, Uint513>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Uint513(Box::new(t))))),
TypeVariant::Uint514 => Box::new(ReadXdrIter::<_, Uint514>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Uint514(Box::new(t))))),
TypeVariant::Str => Box::new(ReadXdrIter::<_, Str>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Str(Box::new(t))))),
TypeVariant::Str2 => Box::new(ReadXdrIter::<_, Str2>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Str2(Box::new(t))))),
TypeVariant::Hash => Box::new(ReadXdrIter::<_, Hash>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Hash(Box::new(t))))),
TypeVariant::Hashes1 => Box::new(ReadXdrIter::<_, Hashes1>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Hashes1(Box::new(t))))),
TypeVariant::Hashes2 => Box::new(ReadXdrIter::<_, Hashes2>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Hashes2(Box::new(t))))),
TypeVariant::Hashes3 => Box::new(ReadXdrIter::<_, Hashes3>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Hashes3(Box::new(t))))),
TypeVariant::OptHash1 => Box::new(ReadXdrIter::<_, OptHash1>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::OptHash1(Box::new(t))))),
TypeVariant::OptHash2 => Box::new(ReadXdrIter::<_, OptHash2>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::OptHash2(Box::new(t))))),
TypeVariant::Int1 => Box::new(ReadXdrIter::<_, Int1>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Int1(Box::new(t))))),
TypeVariant::Int2 => Box::new(ReadXdrIter::<_, Int2>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Int2(Box::new(t))))),
TypeVariant::Int3 => Box::new(ReadXdrIter::<_, Int3>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Int3(Box::new(t))))),
TypeVariant::Int4 => Box::new(ReadXdrIter::<_, Int4>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Int4(Box::new(t))))),
TypeVariant::MyStruct => Box::new(ReadXdrIter::<_, MyStruct>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::MyStruct(Box::new(t))))),
TypeVariant::LotsOfMyStructs => Box::new(ReadXdrIter::<_, LotsOfMyStructs>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::LotsOfMyStructs(Box::new(t))))),
TypeVariant::HasStuff => Box::new(ReadXdrIter::<_, HasStuff>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::HasStuff(Box::new(t))))),
TypeVariant::Color => Box::new(ReadXdrIter::<_, Color>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Color(Box::new(t))))),
TypeVariant::Nester => Box::new(ReadXdrIter::<_, Nester>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Nester(Box::new(t))))),
TypeVariant::NesterNestedEnum => Box::new(ReadXdrIter::<_, NesterNestedEnum>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::NesterNestedEnum(Box::new(t))))),
TypeVariant::NesterNestedStruct => Box::new(ReadXdrIter::<_, NesterNestedStruct>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::NesterNestedStruct(Box::new(t))))),
TypeVariant::NesterNestedUnion => Box::new(ReadXdrIter::<_, NesterNestedUnion>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::NesterNestedUnion(Box::new(t))))),
                }
            }

            #[cfg(feature = "std")]
            pub fn from_xdr<B: AsRef<[u8]>>(v: TypeVariant, bytes: B, limits: Limits) -> Result<Self, Error> {
                let mut cursor = Limited::new(Cursor::new(bytes.as_ref()), limits);
                let t = Self::read_xdr_to_end(v, &mut cursor)?;
                Ok(t)
            }

            #[cfg(feature = "base64")]
            pub fn from_xdr_base64(v: TypeVariant, b64: impl AsRef<[u8]>, limits: Limits) -> Result<Self, Error> {
                let mut b64_reader = Cursor::new(b64);
                let mut dec = Limited::new(base64::read::DecoderReader::new(&mut b64_reader, base64::STANDARD), limits);
                let t = Self::read_xdr_to_end(v, &mut dec)?;
                Ok(t)
            }

            #[cfg(all(feature = "std", feature = "serde_json"))]
            #[deprecated(note = "use from_json")]
            pub fn read_json(v: TypeVariant, r: impl Read) -> Result<Self, Error> {
                Self::from_json(v, r)
            }

            #[cfg(all(feature = "std", feature = "serde_json"))]
            #[allow(clippy::too_many_lines)]
            pub fn from_json(v: TypeVariant, r: impl Read) -> Result<Self, Error> {
                match v {
                    TypeVariant::Uint512 => Ok(Self::Uint512(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Uint513 => Ok(Self::Uint513(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Uint514 => Ok(Self::Uint514(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Str => Ok(Self::Str(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Str2 => Ok(Self::Str2(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Hash => Ok(Self::Hash(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Hashes1 => Ok(Self::Hashes1(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Hashes2 => Ok(Self::Hashes2(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Hashes3 => Ok(Self::Hashes3(Box::new(serde_json::from_reader(r)?))),
TypeVariant::OptHash1 => Ok(Self::OptHash1(Box::new(serde_json::from_reader(r)?))),
TypeVariant::OptHash2 => Ok(Self::OptHash2(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Int1 => Ok(Self::Int1(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Int2 => Ok(Self::Int2(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Int3 => Ok(Self::Int3(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Int4 => Ok(Self::Int4(Box::new(serde_json::from_reader(r)?))),
TypeVariant::MyStruct => Ok(Self::MyStruct(Box::new(serde_json::from_reader(r)?))),
TypeVariant::LotsOfMyStructs => Ok(Self::LotsOfMyStructs(Box::new(serde_json::from_reader(r)?))),
TypeVariant::HasStuff => Ok(Self::HasStuff(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Color => Ok(Self::Color(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Nester => Ok(Self::Nester(Box::new(serde_json::from_reader(r)?))),
TypeVariant::NesterNestedEnum => Ok(Self::NesterNestedEnum(Box::new(serde_json::from_reader(r)?))),
TypeVariant::NesterNestedStruct => Ok(Self::NesterNestedStruct(Box::new(serde_json::from_reader(r)?))),
TypeVariant::NesterNestedUnion => Ok(Self::NesterNestedUnion(Box::new(serde_json::from_reader(r)?))),
                }
            }

            #[cfg(all(feature = "std", feature = "serde_json"))]
            #[allow(clippy::too_many_lines)]
            pub fn deserialize_json<'r, R: serde_json::de::Read<'r>>(v: TypeVariant, r: &mut serde_json::de::Deserializer<R>) -> Result<Self, Error> {
                match v {
                    TypeVariant::Uint512 => Ok(Self::Uint512(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Uint513 => Ok(Self::Uint513(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Uint514 => Ok(Self::Uint514(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Str => Ok(Self::Str(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Str2 => Ok(Self::Str2(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Hash => Ok(Self::Hash(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Hashes1 => Ok(Self::Hashes1(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Hashes2 => Ok(Self::Hashes2(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Hashes3 => Ok(Self::Hashes3(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::OptHash1 => Ok(Self::OptHash1(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::OptHash2 => Ok(Self::OptHash2(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Int1 => Ok(Self::Int1(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Int2 => Ok(Self::Int2(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Int3 => Ok(Self::Int3(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Int4 => Ok(Self::Int4(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::MyStruct => Ok(Self::MyStruct(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::LotsOfMyStructs => Ok(Self::LotsOfMyStructs(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::HasStuff => Ok(Self::HasStuff(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Color => Ok(Self::Color(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Nester => Ok(Self::Nester(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::NesterNestedEnum => Ok(Self::NesterNestedEnum(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::NesterNestedStruct => Ok(Self::NesterNestedStruct(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::NesterNestedUnion => Ok(Self::NesterNestedUnion(Box::new(serde::de::Deserialize::deserialize(r)?))),
                }
            }

            #[cfg(feature = "alloc")]
            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub fn value(&self) -> &dyn core::any::Any {
                #[allow(clippy::match_same_arms)]
                match self {
                    Self::Uint512(ref v) => v.as_ref(),
Self::Uint513(ref v) => v.as_ref(),
Self::Uint514(ref v) => v.as_ref(),
Self::Str(ref v) => v.as_ref(),
Self::Str2(ref v) => v.as_ref(),
Self::Hash(ref v) => v.as_ref(),
Self::Hashes1(ref v) => v.as_ref(),
Self::Hashes2(ref v) => v.as_ref(),
Self::Hashes3(ref v) => v.as_ref(),
Self::OptHash1(ref v) => v.as_ref(),
Self::OptHash2(ref v) => v.as_ref(),
Self::Int1(ref v) => v.as_ref(),
Self::Int2(ref v) => v.as_ref(),
Self::Int3(ref v) => v.as_ref(),
Self::Int4(ref v) => v.as_ref(),
Self::MyStruct(ref v) => v.as_ref(),
Self::LotsOfMyStructs(ref v) => v.as_ref(),
Self::HasStuff(ref v) => v.as_ref(),
Self::Color(ref v) => v.as_ref(),
Self::Nester(ref v) => v.as_ref(),
Self::NesterNestedEnum(ref v) => v.as_ref(),
Self::NesterNestedStruct(ref v) => v.as_ref(),
Self::NesterNestedUnion(ref v) => v.as_ref(),
                }
            }

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn name(&self) -> &'static str {
                match self {
                    Self::Uint512(_) => "Uint512",
Self::Uint513(_) => "Uint513",
Self::Uint514(_) => "Uint514",
Self::Str(_) => "Str",
Self::Str2(_) => "Str2",
Self::Hash(_) => "Hash",
Self::Hashes1(_) => "Hashes1",
Self::Hashes2(_) => "Hashes2",
Self::Hashes3(_) => "Hashes3",
Self::OptHash1(_) => "OptHash1",
Self::OptHash2(_) => "OptHash2",
Self::Int1(_) => "Int1",
Self::Int2(_) => "Int2",
Self::Int3(_) => "Int3",
Self::Int4(_) => "Int4",
Self::MyStruct(_) => "MyStruct",
Self::LotsOfMyStructs(_) => "LotsOfMyStructs",
Self::HasStuff(_) => "HasStuff",
Self::Color(_) => "Color",
Self::Nester(_) => "Nester",
Self::NesterNestedEnum(_) => "NesterNestedEnum",
Self::NesterNestedStruct(_) => "NesterNestedStruct",
Self::NesterNestedUnion(_) => "NesterNestedUnion",
                }
            }

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn variants() -> [TypeVariant; 23] {
                Self::VARIANTS
            }

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn variant(&self) -> TypeVariant {
                match self {
                    Self::Uint512(_) => TypeVariant::Uint512,
Self::Uint513(_) => TypeVariant::Uint513,
Self::Uint514(_) => TypeVariant::Uint514,
Self::Str(_) => TypeVariant::Str,
Self::Str2(_) => TypeVariant::Str2,
Self::Hash(_) => TypeVariant::Hash,
Self::Hashes1(_) => TypeVariant::Hashes1,
Self::Hashes2(_) => TypeVariant::Hashes2,
Self::Hashes3(_) => TypeVariant::Hashes3,
Self::OptHash1(_) => TypeVariant::OptHash1,
Self::OptHash2(_) => TypeVariant::OptHash2,
Self::Int1(_) => TypeVariant::Int1,
Self::Int2(_) => TypeVariant::Int2,
Self::Int3(_) => TypeVariant::Int3,
Self::Int4(_) => TypeVariant::Int4,
Self::MyStruct(_) => TypeVariant::MyStruct,
Self::LotsOfMyStructs(_) => TypeVariant::LotsOfMyStructs,
Self::HasStuff(_) => TypeVariant::HasStuff,
Self::Color(_) => TypeVariant::Color,
Self::Nester(_) => TypeVariant::Nester,
Self::NesterNestedEnum(_) => TypeVariant::NesterNestedEnum,
Self::NesterNestedStruct(_) => TypeVariant::NesterNestedStruct,
Self::NesterNestedUnion(_) => TypeVariant::NesterNestedUnion,
                }
            }
        }

        impl Name for Type {
            #[must_use]
            fn name(&self) -> &'static str {
                Self::name(self)
            }
        }

        impl Variants<TypeVariant> for Type {
            fn variants() -> slice::Iter<'static, TypeVariant> {
                Self::VARIANTS.iter()
            }
        }

        impl WriteXdr for Type {
            #[cfg(feature = "std")]
            #[allow(clippy::too_many_lines)]
            fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
                match self {
                    Self::Uint512(v) => v.write_xdr(w),
Self::Uint513(v) => v.write_xdr(w),
Self::Uint514(v) => v.write_xdr(w),
Self::Str(v) => v.write_xdr(w),
Self::Str2(v) => v.write_xdr(w),
Self::Hash(v) => v.write_xdr(w),
Self::Hashes1(v) => v.write_xdr(w),
Self::Hashes2(v) => v.write_xdr(w),
Self::Hashes3(v) => v.write_xdr(w),
Self::OptHash1(v) => v.write_xdr(w),
Self::OptHash2(v) => v.write_xdr(w),
Self::Int1(v) => v.write_xdr(w),
Self::Int2(v) => v.write_xdr(w),
Self::Int3(v) => v.write_xdr(w),
Self::Int4(v) => v.write_xdr(w),
Self::MyStruct(v) => v.write_xdr(w),
Self::LotsOfMyStructs(v) => v.write_xdr(w),
Self::HasStuff(v) => v.write_xdr(w),
Self::Color(v) => v.write_xdr(w),
Self::Nester(v) => v.write_xdr(w),
Self::NesterNestedEnum(v) => v.write_xdr(w),
Self::NesterNestedStruct(v) => v.write_xdr(w),
Self::NesterNestedUnion(v) => v.write_xdr(w),
                }
            }
        }

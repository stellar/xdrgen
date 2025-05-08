// Module  is generated from:
//  spec/fixtures/generator/enum.x

#![allow(clippy::missing_errors_doc, clippy::unreadable_literal)]

/// `XDR_FILES_SHA256` is a list of pairs of source files and their SHA256 hashes.
pub const XDR_FILES_SHA256: [(&str, &str); 1] = [
  ("spec/fixtures/generator/enum.x", "f764c2a2d349765e611f686e9d416b7f576ea881154d069355a2e75c898daf58")
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

/// MessageType is an XDR Enum defines as:
///
/// ```text
/// enum MessageType
/// {
///     ERROR_MSG,    
///     HELLO,
///     DONT_HAVE,
/// 
///     GET_PEERS,   // gets a list of peers this guy knows about        
///     PEERS,
/// 
///     GET_TX_SET,  // gets a particular txset by hash        
///     TX_SET,    
/// 
///     GET_VALIDATIONS, // gets validations for a given ledger hash        
///     VALIDATIONS,    
/// 
///     TRANSACTION, //pass on a tx you have heard about        
///     JSON_TRANSACTION,
/// 
///     // FBA        
///     GET_FBA_QUORUMSET,        
///     FBA_QUORUMSET,    
///     FBA_MESSAGE
/// };
/// ```
///
// enum
#[derive(Clone, Copy, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[repr(i32)]
pub enum MessageType {
  ErrorMsg = 0,
  Hello = 1,
  DontHave = 2,
  GetPeers = 3,
  Peers = 4,
  GetTxSet = 5,
  TxSet = 6,
  GetValidations = 7,
  Validations = 8,
  Transaction = 9,
  JsonTransaction = 10,
  GetFbaQuorumset = 11,
  FbaQuorumset = 12,
  FbaMessage = 13,
}

        impl MessageType {
            pub const VARIANTS: [MessageType; 14] = [ MessageType::ErrorMsg,
MessageType::Hello,
MessageType::DontHave,
MessageType::GetPeers,
MessageType::Peers,
MessageType::GetTxSet,
MessageType::TxSet,
MessageType::GetValidations,
MessageType::Validations,
MessageType::Transaction,
MessageType::JsonTransaction,
MessageType::GetFbaQuorumset,
MessageType::FbaQuorumset,
MessageType::FbaMessage, ];
            pub const VARIANTS_STR: [&'static str; 14] = [ "ErrorMsg",
"Hello",
"DontHave",
"GetPeers",
"Peers",
"GetTxSet",
"TxSet",
"GetValidations",
"Validations",
"Transaction",
"JsonTransaction",
"GetFbaQuorumset",
"FbaQuorumset",
"FbaMessage", ];

            #[must_use]
            pub const fn name(&self) -> &'static str {
                match self {
                    Self::ErrorMsg => "ErrorMsg",
Self::Hello => "Hello",
Self::DontHave => "DontHave",
Self::GetPeers => "GetPeers",
Self::Peers => "Peers",
Self::GetTxSet => "GetTxSet",
Self::TxSet => "TxSet",
Self::GetValidations => "GetValidations",
Self::Validations => "Validations",
Self::Transaction => "Transaction",
Self::JsonTransaction => "JsonTransaction",
Self::GetFbaQuorumset => "GetFbaQuorumset",
Self::FbaQuorumset => "FbaQuorumset",
Self::FbaMessage => "FbaMessage",
                }
            }

            #[must_use]
            pub const fn variants() -> [MessageType; 14] {
                Self::VARIANTS
            }
        }

        impl Name for MessageType {
            #[must_use]
            fn name(&self) -> &'static str {
                Self::name(self)
            }
        }

        impl Variants<MessageType> for MessageType {
            fn variants() -> slice::Iter<'static, MessageType> {
                Self::VARIANTS.iter()
            }
        }

        impl Enum for MessageType {}

        impl fmt::Display for MessageType {
            fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                f.write_str(self.name())
            }
        }

        impl TryFrom<i32> for MessageType {
            type Error = Error;

            fn try_from(i: i32) -> Result<Self, Error> {
                let e = match i {
                    0 => MessageType::ErrorMsg,
1 => MessageType::Hello,
2 => MessageType::DontHave,
3 => MessageType::GetPeers,
4 => MessageType::Peers,
5 => MessageType::GetTxSet,
6 => MessageType::TxSet,
7 => MessageType::GetValidations,
8 => MessageType::Validations,
9 => MessageType::Transaction,
10 => MessageType::JsonTransaction,
11 => MessageType::GetFbaQuorumset,
12 => MessageType::FbaQuorumset,
13 => MessageType::FbaMessage,
                    #[allow(unreachable_patterns)]
                    _ => return Err(Error::Invalid),
                };
                Ok(e)
            }
        }

        impl From<MessageType> for i32 {
            #[must_use]
            fn from(e: MessageType) -> Self {
                e as Self
            }
        }

        impl ReadXdr for MessageType {
            #[cfg(feature = "std")]
            fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
                r.with_limited_depth(|r| {
                    let e = i32::read_xdr(r)?;
                    let v: Self = e.try_into()?;
                    Ok(v)
                })
            }
        }

        impl WriteXdr for MessageType {
            #[cfg(feature = "std")]
            fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
                w.with_limited_depth(|w| {
                    let i: i32 = (*self).into();
                    i.write_xdr(w)
                })
            }
        }

/// Color is an XDR Enum defines as:
///
/// ```text
/// enum Color {
///     RED=0,  
///     GREEN=1,  
///     BLUE=2  
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
  Green = 1,
  Blue = 2,
}

        impl Color {
            pub const VARIANTS: [Color; 3] = [ Color::Red,
Color::Green,
Color::Blue, ];
            pub const VARIANTS_STR: [&'static str; 3] = [ "Red",
"Green",
"Blue", ];

            #[must_use]
            pub const fn name(&self) -> &'static str {
                match self {
                    Self::Red => "Red",
Self::Green => "Green",
Self::Blue => "Blue",
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
1 => Color::Green,
2 => Color::Blue,
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

/// Color2 is an XDR Enum defines as:
///
/// ```text
/// enum Color2 {
///     RED2=RED,  
///     GREEN2=1,  
///     BLUE2=2  
/// };
/// ```
///
// enum
#[derive(Clone, Copy, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[repr(i32)]
pub enum Color2 {
  Red2 = 0,
  Green2 = 1,
  Blue2 = 2,
}

        impl Color2 {
            pub const VARIANTS: [Color2; 3] = [ Color2::Red2,
Color2::Green2,
Color2::Blue2, ];
            pub const VARIANTS_STR: [&'static str; 3] = [ "Red2",
"Green2",
"Blue2", ];

            #[must_use]
            pub const fn name(&self) -> &'static str {
                match self {
                    Self::Red2 => "Red2",
Self::Green2 => "Green2",
Self::Blue2 => "Blue2",
                }
            }

            #[must_use]
            pub const fn variants() -> [Color2; 3] {
                Self::VARIANTS
            }
        }

        impl Name for Color2 {
            #[must_use]
            fn name(&self) -> &'static str {
                Self::name(self)
            }
        }

        impl Variants<Color2> for Color2 {
            fn variants() -> slice::Iter<'static, Color2> {
                Self::VARIANTS.iter()
            }
        }

        impl Enum for Color2 {}

        impl fmt::Display for Color2 {
            fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                f.write_str(self.name())
            }
        }

        impl TryFrom<i32> for Color2 {
            type Error = Error;

            fn try_from(i: i32) -> Result<Self, Error> {
                let e = match i {
                    0 => Color2::Red2,
1 => Color2::Green2,
2 => Color2::Blue2,
                    #[allow(unreachable_patterns)]
                    _ => return Err(Error::Invalid),
                };
                Ok(e)
            }
        }

        impl From<Color2> for i32 {
            #[must_use]
            fn from(e: Color2) -> Self {
                e as Self
            }
        }

        impl ReadXdr for Color2 {
            #[cfg(feature = "std")]
            fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
                r.with_limited_depth(|r| {
                    let e = i32::read_xdr(r)?;
                    let v: Self = e.try_into()?;
                    Ok(v)
                })
            }
        }

        impl WriteXdr for Color2 {
            #[cfg(feature = "std")]
            fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
                w.with_limited_depth(|w| {
                    let i: i32 = (*self).into();
                    i.write_xdr(w)
                })
            }
        }

/// Color3 is an XDR Enum defines as:
///
/// ```text
/// enum Color3 {
///     RED_1=1,
///     RED_2_TWO=2,
///     RED_3=3
/// };
/// ```
///
// enum
#[derive(Clone, Copy, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
#[cfg_attr(feature = "arbitrary", derive(Arbitrary))]
#[cfg_attr(all(feature = "serde", feature = "alloc"), derive(serde::Serialize, serde::Deserialize), serde(rename_all = "snake_case"))]
#[cfg_attr(feature = "schemars", derive(schemars::JsonSchema))]
#[repr(i32)]
pub enum Color3 {
  R1 = 1,
  R2Two = 2,
  R3 = 3,
}

        impl Color3 {
            pub const VARIANTS: [Color3; 3] = [ Color3::R1,
Color3::R2Two,
Color3::R3, ];
            pub const VARIANTS_STR: [&'static str; 3] = [ "R1",
"R2Two",
"R3", ];

            #[must_use]
            pub const fn name(&self) -> &'static str {
                match self {
                    Self::R1 => "R1",
Self::R2Two => "R2Two",
Self::R3 => "R3",
                }
            }

            #[must_use]
            pub const fn variants() -> [Color3; 3] {
                Self::VARIANTS
            }
        }

        impl Name for Color3 {
            #[must_use]
            fn name(&self) -> &'static str {
                Self::name(self)
            }
        }

        impl Variants<Color3> for Color3 {
            fn variants() -> slice::Iter<'static, Color3> {
                Self::VARIANTS.iter()
            }
        }

        impl Enum for Color3 {}

        impl fmt::Display for Color3 {
            fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                f.write_str(self.name())
            }
        }

        impl TryFrom<i32> for Color3 {
            type Error = Error;

            fn try_from(i: i32) -> Result<Self, Error> {
                let e = match i {
                    1 => Color3::R1,
2 => Color3::R2Two,
3 => Color3::R3,
                    #[allow(unreachable_patterns)]
                    _ => return Err(Error::Invalid),
                };
                Ok(e)
            }
        }

        impl From<Color3> for i32 {
            #[must_use]
            fn from(e: Color3) -> Self {
                e as Self
            }
        }

        impl ReadXdr for Color3 {
            #[cfg(feature = "std")]
            fn read_xdr<R: Read>(r: &mut Limited<R>) -> Result<Self, Error> {
                r.with_limited_depth(|r| {
                    let e = i32::read_xdr(r)?;
                    let v: Self = e.try_into()?;
                    Ok(v)
                })
            }
        }

        impl WriteXdr for Color3 {
            #[cfg(feature = "std")]
            fn write_xdr<W: Write>(&self, w: &mut Limited<W>) -> Result<(), Error> {
                w.with_limited_depth(|w| {
                    let i: i32 = (*self).into();
                    i.write_xdr(w)
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
            MessageType,
Color,
Color2,
Color3,
        }

        impl TypeVariant {
            pub const VARIANTS: [TypeVariant; 4] = [ TypeVariant::MessageType,
TypeVariant::Color,
TypeVariant::Color2,
TypeVariant::Color3, ];
            pub const VARIANTS_STR: [&'static str; 4] = [ "MessageType",
"Color",
"Color2",
"Color3", ];

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn name(&self) -> &'static str {
                match self {
                    Self::MessageType => "MessageType",
Self::Color => "Color",
Self::Color2 => "Color2",
Self::Color3 => "Color3",
                }
            }

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn variants() -> [TypeVariant; 4] {
                Self::VARIANTS
            }

            #[cfg(feature = "schemars")]
            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub fn json_schema(&self, gen: schemars::gen::SchemaGenerator) -> schemars::schema::RootSchema {
                match self {
                    Self::MessageType => gen.into_root_schema_for::<MessageType>(),
Self::Color => gen.into_root_schema_for::<Color>(),
Self::Color2 => gen.into_root_schema_for::<Color2>(),
Self::Color3 => gen.into_root_schema_for::<Color3>(),
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
                    "MessageType" => Ok(Self::MessageType),
"Color" => Ok(Self::Color),
"Color2" => Ok(Self::Color2),
"Color3" => Ok(Self::Color3),
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
            MessageType(Box<MessageType>),
Color(Box<Color>),
Color2(Box<Color2>),
Color3(Box<Color3>),
        }

        impl Type {
            pub const VARIANTS: [TypeVariant; 4] = [ TypeVariant::MessageType,
TypeVariant::Color,
TypeVariant::Color2,
TypeVariant::Color3, ];
            pub const VARIANTS_STR: [&'static str; 4] = [ "MessageType",
"Color",
"Color2",
"Color3", ];

            #[cfg(feature = "std")]
            #[allow(clippy::too_many_lines)]
            pub fn read_xdr<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Result<Self, Error> {
                match v {
                    TypeVariant::MessageType => r.with_limited_depth(|r| Ok(Self::MessageType(Box::new(MessageType::read_xdr(r)?)))),
TypeVariant::Color => r.with_limited_depth(|r| Ok(Self::Color(Box::new(Color::read_xdr(r)?)))),
TypeVariant::Color2 => r.with_limited_depth(|r| Ok(Self::Color2(Box::new(Color2::read_xdr(r)?)))),
TypeVariant::Color3 => r.with_limited_depth(|r| Ok(Self::Color3(Box::new(Color3::read_xdr(r)?)))),
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
                    TypeVariant::MessageType => Box::new(ReadXdrIter::<_, MessageType>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::MessageType(Box::new(t))))),
TypeVariant::Color => Box::new(ReadXdrIter::<_, Color>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Color(Box::new(t))))),
TypeVariant::Color2 => Box::new(ReadXdrIter::<_, Color2>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Color2(Box::new(t))))),
TypeVariant::Color3 => Box::new(ReadXdrIter::<_, Color3>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Color3(Box::new(t))))),
                }
            }

            #[cfg(feature = "std")]
            #[allow(clippy::too_many_lines)]
            pub fn read_xdr_framed_iter<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Box<dyn Iterator<Item=Result<Self, Error>> + '_> {
                match v {
                    TypeVariant::MessageType => Box::new(ReadXdrIter::<_, Frame<MessageType>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::MessageType(Box::new(t.0))))),
TypeVariant::Color => Box::new(ReadXdrIter::<_, Frame<Color>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Color(Box::new(t.0))))),
TypeVariant::Color2 => Box::new(ReadXdrIter::<_, Frame<Color2>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Color2(Box::new(t.0))))),
TypeVariant::Color3 => Box::new(ReadXdrIter::<_, Frame<Color3>>::new(&mut r.inner, r.limits.clone()).map(|r| r.map(|t| Self::Color3(Box::new(t.0))))),
                }
            }

            #[cfg(feature = "base64")]
            #[allow(clippy::too_many_lines)]
            pub fn read_xdr_base64_iter<R: Read>(v: TypeVariant, r: &mut Limited<R>) -> Box<dyn Iterator<Item=Result<Self, Error>> + '_> {
                let dec = base64::read::DecoderReader::new(&mut r.inner, base64::STANDARD);
                match v {
                    TypeVariant::MessageType => Box::new(ReadXdrIter::<_, MessageType>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::MessageType(Box::new(t))))),
TypeVariant::Color => Box::new(ReadXdrIter::<_, Color>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Color(Box::new(t))))),
TypeVariant::Color2 => Box::new(ReadXdrIter::<_, Color2>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Color2(Box::new(t))))),
TypeVariant::Color3 => Box::new(ReadXdrIter::<_, Color3>::new(dec, r.limits.clone()).map(|r| r.map(|t| Self::Color3(Box::new(t))))),
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
                    TypeVariant::MessageType => Ok(Self::MessageType(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Color => Ok(Self::Color(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Color2 => Ok(Self::Color2(Box::new(serde_json::from_reader(r)?))),
TypeVariant::Color3 => Ok(Self::Color3(Box::new(serde_json::from_reader(r)?))),
                }
            }

            #[cfg(all(feature = "std", feature = "serde_json"))]
            #[allow(clippy::too_many_lines)]
            pub fn deserialize_json<'r, R: serde_json::de::Read<'r>>(v: TypeVariant, r: &mut serde_json::de::Deserializer<R>) -> Result<Self, Error> {
                match v {
                    TypeVariant::MessageType => Ok(Self::MessageType(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Color => Ok(Self::Color(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Color2 => Ok(Self::Color2(Box::new(serde::de::Deserialize::deserialize(r)?))),
TypeVariant::Color3 => Ok(Self::Color3(Box::new(serde::de::Deserialize::deserialize(r)?))),
                }
            }

            #[cfg(feature = "alloc")]
            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub fn value(&self) -> &dyn core::any::Any {
                #[allow(clippy::match_same_arms)]
                match self {
                    Self::MessageType(ref v) => v.as_ref(),
Self::Color(ref v) => v.as_ref(),
Self::Color2(ref v) => v.as_ref(),
Self::Color3(ref v) => v.as_ref(),
                }
            }

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn name(&self) -> &'static str {
                match self {
                    Self::MessageType(_) => "MessageType",
Self::Color(_) => "Color",
Self::Color2(_) => "Color2",
Self::Color3(_) => "Color3",
                }
            }

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn variants() -> [TypeVariant; 4] {
                Self::VARIANTS
            }

            #[must_use]
            #[allow(clippy::too_many_lines)]
            pub const fn variant(&self) -> TypeVariant {
                match self {
                    Self::MessageType(_) => TypeVariant::MessageType,
Self::Color(_) => TypeVariant::Color,
Self::Color2(_) => TypeVariant::Color2,
Self::Color3(_) => TypeVariant::Color3,
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
                    Self::MessageType(v) => v.write_xdr(w),
Self::Color(v) => v.write_xdr(w),
Self::Color2(v) => v.write_xdr(w),
Self::Color3(v) => v.write_xdr(w),
                }
            }
        }

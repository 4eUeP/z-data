{-|
Module      :  Z.Data.PrimRef.PrimSTRef
Description :  Primitive ST Reference
Copyright   :  (c) Dong Han 2017~2019
License     :  BSD-style

Maintainer  :  winterland1989@gmail.com
Stability   :  experimental
Portability :  portable

This package provide fast unboxed references for ST monad. Unboxed reference is implemented using single cell MutableByteArray s to eliminate indirection overhead which MutVar# s a carry, on the otherhand unboxed reference only support limited type(instances of 'Prim' class).
-}


module Z.Data.PrimRef.PrimSTRef
  ( -- * Unboxed ST references
    PrimSTRef(..)
  , newPrimSTRef
  , readPrimSTRef
  , writePrimSTRef
  , modifyPrimSTRef
  ) where

import Data.Primitive.Types
import Data.Primitive.ByteArray
import GHC.ST
import GHC.Exts

-- | A mutable variable in the ST monad which can hold an instance of 'Prim'.
--
newtype PrimSTRef s a = PrimSTRef (MutableByteArray s)

-- | Build a new 'PrimSTRef'
--
newPrimSTRef :: Prim a => a -> ST s (PrimSTRef s a)
newPrimSTRef x = do
     mba <- newByteArray (I# (sizeOf# x))
     writeByteArray mba 0 x
     return (PrimSTRef mba)
{-# INLINE newPrimSTRef #-}

-- | Read the value of an 'PrimSTRef'
--
readPrimSTRef :: Prim a => PrimSTRef s a -> ST s a
readPrimSTRef (PrimSTRef mba) = readByteArray mba 0
{-# INLINE readPrimSTRef #-}

-- | Write a new value into an 'PrimSTRef'
--
writePrimSTRef :: Prim a => PrimSTRef s a -> a -> ST s ()
writePrimSTRef (PrimSTRef mba) x = writeByteArray mba 0 x
{-# INLINE writePrimSTRef #-}

-- | Mutate the contents of an 'PrimSTRef'.
--
--  Unboxed reference is always strict on the value it hold.
--
modifyPrimSTRef :: Prim a => PrimSTRef s a -> (a -> a) -> ST s ()
modifyPrimSTRef ref f = readPrimSTRef ref >>= writePrimSTRef ref . f
{-# INLINE modifyPrimSTRef #-}

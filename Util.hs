module Util where

import DataType
import Input
import Data.List(sort)    

-- 整数のペアのリストからテトリスブロックを作る関数
maketet :: [(Int,Int)] -> Tetromino Cartesian
maketet = Tetromino . map makecart
  where
    makecart :: (Int,Int) -> Cartesian
    makecart x = Cartesian (fst x) (snd x)

tetromino =
 [
    maketet [(0,0),(1,0),(0,1),(1,1)] -- O
  , maketet [(0,0),(1,0),(2,0),(3,0)] -- I
  , maketet [(0,0),(1,0),(1,1),(2,1)] -- Z
  , maketet [(0,1),(1,1),(1,0),(2,0)] -- S
  , maketet [(0,0),(1,0),(2,0),(2,1)] -- J
  , maketet [(2,0),(1,0),(0,0),(0,1)] -- L
  , maketet [(0,0),(1,0),(2,0),(1,1)] -- T
 ]

-- 平行移動関数
ptrans :: Cartesian -> Tetromino Cartesian -> Tetromino Cartesian
ptrans p = fmap (+p)
-- ptrans p = bind (+ p)

-- 反時計90度の単純回転関数
simpleRotate :: Tetromino Cartesian -> Tetromino Cartesian
simpleRotate = fmap mat
  where
    mat :: Cartesian -> Cartesian
    mat c = Cartesian (y c) (negate (x c))
        
-- 中心座標での回転関数
rotate :: Tetromino Cartesian -> Tetromino Cartesian
rotate t = ptrans halfc . simpleRotate . ptrans (negate halfc) $ t
  where
    halfc :: Cartesian
    halfc = head $ tail $ blocks t

rotaten :: Tetromino Cartesian -> Int -> Tetromino Cartesian
rotaten t n | turn == 0 = t
            | turn == 1 = rotate t
            | turn == 2 = rotate $ rotate t
            | turn == 3 = rotate $ rotate $ rotate t
    where turn = mod n 4

-- Tetromino を文字列に(デバッグ用?)
showOne :: Tetromino Cartesian -> String
showOne = showOne' (Cartesian 0 0) . sort . blocks . ptrans (Cartesian 2 2)
showOne' a (b:bs)
  | a == b  = '*' : showOne' right bs
  | not $ (y a) == (y b) = '\n' : showOne' newline (b:bs)
  | otherwise = ' ' : showOne' right (b:bs)
    where
      right = a + (Cartesian 1 0)
      newline = Cartesian 0 ((y a) + 1)
showOne' _ [] = []

-- showOne を ghci で見るため
putOne :: Tetromino Cartesian -> IO ()
putOne = putStrLn . showOne

-- times :: a -> (a -> a) -> Int -> a
-- times x _ 0 = x
-- times x f n = times (f x) f (n-1)
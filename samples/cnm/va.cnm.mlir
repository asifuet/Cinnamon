#map = affine_map<(d0) -> (d0 floordiv 8192, (d0 mod 8192) floordiv 64, d0 mod 64)>
#map1 = affine_map<(d0, d1, d2) -> (d0 * 8192 + d1 * 64 + d2)>
#map2 = affine_map<(d0) -> (d0 floordiv 4096, (d0 mod 4096) floordiv 32, d0 mod 32)>
#map3 = affine_map<(d0, d1, d2) -> (d0 * 4096 + d1 * 32 + d2)>
module {
  func.func @va_8(%arg0: tensor<8x2097152xi32>, %arg1: tensor<8x2097152xi32>) {
    %cst = arith.constant dense<16777216> : tensor<1xi64>
    %cst_0 = arith.constant dense<[8, 2097152]> : tensor<2xi64>
    %reshape = tensor.reshape %arg0(%cst) : (tensor<8x2097152xi32>, tensor<1xi64>) -> tensor<16777216xi32>
    %reshape_1 = tensor.reshape %arg1(%cst) : (tensor<8x2097152xi32>, tensor<1xi64>) -> tensor<16777216xi32>
    %0 = tensor.empty() : tensor<16777216xi32>
    %1 = affine.for %arg2 = 0 to 16777216 step 65536 iter_args(%arg3 = %0) -> (tensor<16777216xi32>) {
      %c65536 = arith.constant 65536 : index
      %2 = arith.muli %arg2, %c65536 : index
      %extracted_slice = tensor.extract_slice %reshape[%2] [65536] [1] : tensor<16777216xi32> to tensor<65536xi32>
      %extracted_slice_3 = tensor.extract_slice %reshape_1[%2] [65536] [1] : tensor<16777216xi32> to tensor<65536xi32>
      %3 = cnm.workgroup : !cnm.workgroup<8x128>
      %cst_4 = arith.constant dense<0> : tensor<65536xi32>
      %4 = cnm.alloc() for %3 : !cnm.buffer<64xi32 on 8x128, level 0>
      %5 = cnm.scatter %extracted_slice into %4[#map] of %3 : tensor<65536xi32> into !cnm.buffer<64xi32 on 8x128, level 0>
      %6 = cnm.alloc() for %3 : !cnm.buffer<64xi32 on 8x128, level 0>
      %7 = cnm.scatter %extracted_slice_3 into %6[#map] of %3 : tensor<65536xi32> into !cnm.buffer<64xi32 on 8x128, level 0>
      %8 = cnm.alloc() for %3 : !cnm.buffer<64xi32 on 8x128, level 0>
      %9 = cnm.scatter %cst_4 into %8[#map] of %3 : tensor<65536xi32> into !cnm.buffer<64xi32 on 8x128, level 0>
      %10 = cnm.launch %3 in(%4, %6 : !cnm.buffer<64xi32 on 8x128, level 0>, !cnm.buffer<64xi32 on 8x128, level 0>) out(%8 : !cnm.buffer<64xi32 on 8x128, level 0>) on !cnm.workgroup<8x128> {
      ^bb0(%arg4: memref<64xi32>, %arg5: memref<64xi32>, %arg6: memref<64xi32>):
        linalg.add ins(%arg4, %arg5 : memref<64xi32>, memref<64xi32>) outs(%arg6 : memref<64xi32>)
      }
      %output, %token = cnm.gather %8[#map1] of %3 : !cnm.buffer<64xi32 on 8x128, level 0> into tensor<65536xi32>
      %inserted_slice = tensor.insert_slice %output into %arg3[%2] [65536] [1] : tensor<65536xi32> into tensor<16777216xi32>
      affine.yield %inserted_slice : tensor<16777216xi32>
    }
    %reshape_2 = tensor.reshape %1(%cst_0) : (tensor<16777216xi32>, tensor<2xi64>) -> tensor<8x2097152xi32>
    return
  }
  func.func @va_16(%arg0: tensor<16x1048576xi32>, %arg1: tensor<16x1048576xi32>) {
    %cst = arith.constant dense<16777216> : tensor<1xi64>
    %cst_0 = arith.constant dense<[16, 1048576]> : tensor<2xi64>
    %reshape = tensor.reshape %arg0(%cst) : (tensor<16x1048576xi32>, tensor<1xi64>) -> tensor<16777216xi32>
    %reshape_1 = tensor.reshape %arg1(%cst) : (tensor<16x1048576xi32>, tensor<1xi64>) -> tensor<16777216xi32>
    %0 = tensor.empty() : tensor<16777216xi32>
    %1 = affine.for %arg2 = 0 to 16777216 step 65536 iter_args(%arg3 = %0) -> (tensor<16777216xi32>) {
      %c65536 = arith.constant 65536 : index
      %2 = arith.muli %arg2, %c65536 : index
      %extracted_slice = tensor.extract_slice %reshape[%2] [65536] [1] : tensor<16777216xi32> to tensor<65536xi32>
      %extracted_slice_3 = tensor.extract_slice %reshape_1[%2] [65536] [1] : tensor<16777216xi32> to tensor<65536xi32>
      %3 = cnm.workgroup : !cnm.workgroup<16x128>
      %cst_4 = arith.constant dense<0> : tensor<65536xi32>
      %4 = cnm.alloc() for %3 : !cnm.buffer<32xi32 on 16x128, level 0>
      %5 = cnm.scatter %extracted_slice into %4[#map2] of %3 : tensor<65536xi32> into !cnm.buffer<32xi32 on 16x128, level 0>
      %6 = cnm.alloc() for %3 : !cnm.buffer<32xi32 on 16x128, level 0>
      %7 = cnm.scatter %extracted_slice_3 into %6[#map2] of %3 : tensor<65536xi32> into !cnm.buffer<32xi32 on 16x128, level 0>
      %8 = cnm.alloc() for %3 : !cnm.buffer<32xi32 on 16x128, level 0>
      %9 = cnm.scatter %cst_4 into %8[#map2] of %3 : tensor<65536xi32> into !cnm.buffer<32xi32 on 16x128, level 0>
      %10 = cnm.launch %3 in(%4, %6 : !cnm.buffer<32xi32 on 16x128, level 0>, !cnm.buffer<32xi32 on 16x128, level 0>) out(%8 : !cnm.buffer<32xi32 on 16x128, level 0>) on !cnm.workgroup<16x128> {
      ^bb0(%arg4: memref<32xi32>, %arg5: memref<32xi32>, %arg6: memref<32xi32>):
        linalg.add ins(%arg4, %arg5 : memref<32xi32>, memref<32xi32>) outs(%arg6 : memref<32xi32>)
      }
      %output, %token = cnm.gather %8[#map3] of %3 : !cnm.buffer<32xi32 on 16x128, level 0> into tensor<65536xi32>
      %inserted_slice = tensor.insert_slice %output into %arg3[%2] [65536] [1] : tensor<65536xi32> into tensor<16777216xi32>
      affine.yield %inserted_slice : tensor<16777216xi32>
    }
    %reshape_2 = tensor.reshape %1(%cst_0) : (tensor<16777216xi32>, tensor<2xi64>) -> tensor<16x1048576xi32>
    return
  }
}


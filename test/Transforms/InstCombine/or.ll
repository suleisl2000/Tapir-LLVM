; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:128:128"

define i32 @test1(i32 %A) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    ret i32 %A
;
  %B = or i32 %A, 0
  ret i32 %B
}

define i32 @test2(i32 %A) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    ret i32 -1
;
  %B = or i32 %A, -1
  ret i32 %B
}

define i8 @test2a(i8 %A) {
; CHECK-LABEL: @test2a(
; CHECK-NEXT:    ret i8 -1
;
  %B = or i8 %A, -1
  ret i8 %B
}

define i1 @test3(i1 %A) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    ret i1 %A
;
  %B = or i1 %A, false
  ret i1 %B
}

define i1 @test4(i1 %A) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    ret i1 true
;
  %B = or i1 %A, true
  ret i1 %B
}

define i1 @test5(i1 %A) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    ret i1 %A
;
  %B = or i1 %A, %A
  ret i1 %B
}

define i32 @test6(i32 %A) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    ret i32 %A
;
  %B = or i32 %A, %A
  ret i32 %B
}

; A | ~A == -1
define i32 @test7(i32 %A) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    ret i32 -1
;
  %NotA = xor i32 -1, %A
  %B = or i32 %A, %NotA
  ret i32 %B
}

define i8 @test8(i8 %A) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    ret i8 -1
;
  %B = or i8 %A, -2
  %C = or i8 %B, 1
  ret i8 %C
}

; Test that (A|c1)|(B|c2) == (A|B)|(c1|c2)
define i8 @test9(i8 %A, i8 %B) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    ret i8 -1
;
  %C = or i8 %A, 1
  %D = or i8 %B, -2
  %E = or i8 %C, %D
  ret i8 %E
}

define i8 @test10(i8 %A) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    ret i8 -2
;
  %B = or i8 %A, 1
  %C = and i8 %B, -2
  ; (X & C1) | C2 --> (X | C2) & (C1|C2)
  %D = or i8 %C, -2
  ret i8 %D
}

define i8 @test11(i8 %A) {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    ret i8 -1
;
  %B = or i8 %A, -2
  %C = xor i8 %B, 13
  ; (X ^ C1) | C2 --> (X | C2) ^ (C1&~C2)
  %D = or i8 %C, 1
  %E = xor i8 %D, 12
  ret i8 %E
}

define i32 @test12(i32 %A) {
        ; Should be eliminated
; CHECK-LABEL: @test12(
; CHECK-NEXT:    [[C:%.*]] = and i32 %A, 8
; CHECK-NEXT:    ret i32 [[C]]
;
  %B = or i32 %A, 4
  %C = and i32 %B, 8
  ret i32 %C
}

define i32 @test13(i32 %A) {
; CHECK-LABEL: @test13(
; CHECK-NEXT:    ret i32 8
;
  %B = or i32 %A, 12
  ; Always equal to 8
  %C = and i32 %B, 8
  ret i32 %C
}

define i1 @test14(i32 %A, i32 %B) {
; CHECK-LABEL: @test14(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ne i32 %A, %B
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %C1 = icmp ult i32 %A, %B
  %C2 = icmp ugt i32 %A, %B
  ; (A < B) | (A > B) === A != B
  %D = or i1 %C1, %C2
  ret i1 %D
}

define i1 @test15(i32 %A, i32 %B) {
; CHECK-LABEL: @test15(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ule i32 %A, %B
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %C1 = icmp ult i32 %A, %B
  %C2 = icmp eq i32 %A, %B
  ; (A < B) | (A == B) === A <= B
  %D = or i1 %C1, %C2
  ret i1 %D
}

define i32 @test16(i32 %A) {
; CHECK-LABEL: @test16(
; CHECK-NEXT:    ret i32 %A
;
  %B = and i32 %A, 1
  ; -2 = ~1
  %C = and i32 %A, -2
  ; %D = and int %B, -1 == %B
  %D = or i32 %B, %C
  ret i32 %D
}

define i32 @test17(i32 %A) {
; CHECK-LABEL: @test17(
; CHECK-NEXT:    [[D:%.*]] = and i32 %A, 5
; CHECK-NEXT:    ret i32 [[D]]
;
  %B = and i32 %A, 1
  %C = and i32 %A, 4
  ; %D = and int %B, 5
  %D = or i32 %B, %C
  ret i32 %D
}

define i1 @test18(i32 %A) {
; CHECK-LABEL: @test18(
; CHECK-NEXT:    [[A_OFF:%.*]] = add i32 %A, -50
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i32 [[A_OFF]], 49
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %B = icmp sge i32 %A, 100
  %C = icmp slt i32 %A, 50
  ;; (A-50) >u 50
  %D = or i1 %B, %C
  ret i1 %D
}

define i1 @test19(i32 %A) {
; CHECK-LABEL: @test19(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 %A, 1
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 51
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %B = icmp eq i32 %A, 50
  %C = icmp eq i32 %A, 51
  ;; (A&-2) == 50
  %D = or i1 %B, %C
  ret i1 %D
}

define i32 @test20(i32 %x) {
; CHECK-LABEL: @test20(
; CHECK-NEXT:    ret i32 %x
;
  %y = and i32 %x, 123
  %z = or i32 %y, %x
  ret i32 %z
}

define i32 @test21(i32 %tmp.1) {
; CHECK-LABEL: @test21(
; CHECK-NEXT:    [[TMP_1_MASK1:%.*]] = add i32 %tmp.1, 2
; CHECK-NEXT:    ret i32 [[TMP_1_MASK1]]
;
  %tmp.1.mask1 = add i32 %tmp.1, 2
  %tmp.3 = and i32 %tmp.1.mask1, -2
  %tmp.5 = and i32 %tmp.1, 1
  ;; add tmp.1, 2
  %tmp.6 = or i32 %tmp.5, %tmp.3
  ret i32 %tmp.6
}

define i32 @test22(i32 %B) {
; CHECK-LABEL: @test22(
; CHECK-NEXT:    ret i32 %B
;
  %ELIM41 = and i32 %B, 1
  %ELIM7 = and i32 %B, -2
  %ELIM5 = or i32 %ELIM41, %ELIM7
  ret i32 %ELIM5
}

define i16 @test23(i16 %A) {
; CHECK-LABEL: @test23(
; CHECK-NEXT:    [[B:%.*]] = lshr i16 %A, 1
; CHECK-NEXT:    [[D:%.*]] = xor i16 [[B]], -24575
; CHECK-NEXT:    ret i16 [[D]]
;
  %B = lshr i16 %A, 1
  ;; fold or into xor
  %C = or i16 %B, -32768
  %D = xor i16 %C, 8193
  ret i16 %D
}

; PR1738
define i1 @test24(double %X, double %Y) {
; CHECK-LABEL: @test24(
; CHECK-NEXT:    [[TMP1:%.*]] = fcmp uno double %Y, %X
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %tmp9 = fcmp uno double %X, 0.000000e+00
  %tmp13 = fcmp uno double %Y, 0.000000e+00
  %bothcond = or i1 %tmp13, %tmp9
  ret i1 %bothcond
}

; PR3266 & PR5276
define i1 @test25(i32 %A, i32 %B) {
; CHECK-LABEL: @test25(
; CHECK-NEXT:    [[NOTLHS:%.*]] = icmp ne i32 %A, 0
; CHECK-NEXT:    [[NOTRHS:%.*]] = icmp ne i32 %B, 57
; CHECK-NEXT:    [[F:%.*]] = and i1 [[NOTRHS]], [[NOTLHS]]
; CHECK-NEXT:    ret i1 [[F]]
;
  %C = icmp eq i32 %A, 0
  %D = icmp eq i32 %B, 57
  %E = or i1 %C, %D
  %F = xor i1 %E, -1
  ret i1 %F
}

; PR5634
define i1 @test26(i32 %A, i32 %B) {
; CHECK-LABEL: @test26(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 %A, %B
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 0
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %C1 = icmp eq i32 %A, 0
  %C2 = icmp eq i32 %B, 0
  ; (A == 0) & (A == 0)   -->   (A|B) == 0
  %D = and i1 %C1, %C2
  ret i1 %D
}

define i1 @test27(i32* %A, i32* %B) {
; CHECK-LABEL: @test27(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i32* %A, null
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32* %B, null
; CHECK-NEXT:    [[E:%.*]] = and i1 [[TMP1]], [[TMP2]]
; CHECK-NEXT:    ret i1 [[E]]
;
  %C1 = ptrtoint i32* %A to i32
  %C2 = ptrtoint i32* %B to i32
  %D = or i32 %C1, %C2
  %E = icmp eq i32 %D, 0
  ret i1 %E
}

define <2 x i1> @test27vec(<2 x i32*> %A, <2 x i32*> %B) {
; CHECK-LABEL: @test27vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq <2 x i32*> %A, zeroinitializer
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq <2 x i32*> %B, zeroinitializer
; CHECK-NEXT:    [[E:%.*]] = and <2 x i1> [[TMP1]], [[TMP2]]
; CHECK-NEXT:    ret <2 x i1> [[E]]
;
  %C1 = ptrtoint <2 x i32*> %A to <2 x i32>
  %C2 = ptrtoint <2 x i32*> %B to <2 x i32>
  %D = or <2 x i32> %C1, %C2
  %E = icmp eq <2 x i32> %D, zeroinitializer
  ret <2 x i1> %E
}

; PR5634
define i1 @test28(i32 %A, i32 %B) {
; CHECK-LABEL: @test28(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 %A, %B
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32 [[TMP1]], 0
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %C1 = icmp ne i32 %A, 0
  %C2 = icmp ne i32 %B, 0
  ; (A != 0) | (A != 0)   -->   (A|B) != 0
  %D = or i1 %C1, %C2
  ret i1 %D
}

define i1 @test29(i32* %A, i32* %B) {
; CHECK-LABEL: @test29(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ne i32* %A, null
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32* %B, null
; CHECK-NEXT:    [[E:%.*]] = or i1 [[TMP1]], [[TMP2]]
; CHECK-NEXT:    ret i1 [[E]]
;
  %C1 = ptrtoint i32* %A to i32
  %C2 = ptrtoint i32* %B to i32
  %D = or i32 %C1, %C2
  %E = icmp ne i32 %D, 0
  ret i1 %E
}

define <2 x i1> @test29vec(<2 x i32*> %A, <2 x i32*> %B) {
; CHECK-LABEL: @test29vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ne <2 x i32*> %A, zeroinitializer
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne <2 x i32*> %B, zeroinitializer
; CHECK-NEXT:    [[E:%.*]] = or <2 x i1> [[TMP1]], [[TMP2]]
; CHECK-NEXT:    ret <2 x i1> [[E]]
;
  %C1 = ptrtoint <2 x i32*> %A to <2 x i32>
  %C2 = ptrtoint <2 x i32*> %B to <2 x i32>
  %D = or <2 x i32> %C1, %C2
  %E = icmp ne <2 x i32> %D, zeroinitializer
  ret <2 x i1> %E
}

; PR4216
define i32 @test30(i32 %A) {
; CHECK-LABEL: @test30(
; CHECK-NEXT:    [[D:%.*]] = and i32 %A, -58312
; CHECK-NEXT:    [[E:%.*]] = or i32 [[D]], 32962
; CHECK-NEXT:    ret i32 [[E]]
;
  %B = or i32 %A, 32962
  %C = and i32 %A, -65536
  %D = and i32 %B, 40186
  %E = or i32 %D, %C
  ret i32 %E
}

; PR4216
define i64 @test31(i64 %A) {
; CHECK-LABEL: @test31(
; CHECK-NEXT:    [[E:%.*]] = and i64 %A, 4294908984
; CHECK-NEXT:    [[F:%.*]] = or i64 [[E]], 32962
; CHECK-NEXT:    ret i64 [[F]]
;
  %B = or i64 %A, 194
  %D = and i64 %B, 250

  %C = or i64 %A, 32768
  %E = and i64 %C, 4294941696

  %F = or i64 %D, %E
  ret i64 %F
}

; codegen is mature enough to handle vector selects.
define <4 x i32> @test32(<4 x i1> %and.i1352, <4 x i32> %vecinit6.i176, <4 x i32> %vecinit6.i191) {
; CHECK-LABEL: @test32(
; CHECK-NEXT:    [[OR_I:%.*]] = select <4 x i1> %and.i1352, <4 x i32> %vecinit6.i176, <4 x i32> %vecinit6.i191
; CHECK-NEXT:    ret <4 x i32> [[OR_I]]
;
  %and.i135 = sext <4 x i1> %and.i1352 to <4 x i32>
  %and.i129 = and <4 x i32> %vecinit6.i176, %and.i135
  %neg.i = xor <4 x i32> %and.i135, <i32 -1, i32 -1, i32 -1, i32 -1>
  %and.i = and <4 x i32> %vecinit6.i191, %neg.i
  %or.i = or <4 x i32> %and.i, %and.i129
  ret <4 x i32> %or.i
}

define i1 @test33(i1 %X, i1 %Y) {
; CHECK-LABEL: @test33(
; CHECK-NEXT:    [[B:%.*]] = or i1 %X, %Y
; CHECK-NEXT:    ret i1 [[B]]
;
  %a = or i1 %X, %Y
  %b = or i1 %a, %X
  ret i1 %b
}

define i32 @test34(i32 %X, i32 %Y) {
; CHECK-LABEL: @test34(
; CHECK-NEXT:    [[B:%.*]] = or i32 %X, %Y
; CHECK-NEXT:    ret i32 [[B]]
;
  %a = or i32 %X, %Y
  %b = or i32 %Y, %a
  ret i32 %b
}

define i32 @test35(i32 %a, i32 %b) {
; CHECK-LABEL: @test35(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 %a, %b
; CHECK-NEXT:    [[TMP2:%.*]] = or i32 [[TMP1]], 1135
; CHECK-NEXT:    ret i32 [[TMP2]]
;
  %1 = or i32 %a, 1135
  %2 = or i32 %1, %b
  ret i32 %2
}

define i1 @test36(i32 %x) {
; CHECK-LABEL: @test36(
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 %x, -23
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X_OFF]], 3
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %cmp1 = icmp eq i32 %x, 23
  %cmp2 = icmp eq i32 %x, 24
  %ret1 = or i1 %cmp1, %cmp2
  %cmp3 = icmp eq i32 %x, 25
  %ret2 = or i1 %ret1, %cmp3
  ret i1 %ret2
}

define i32 @orsext_to_sel(i32 %x, i1 %y) {
; CHECK-LABEL: @orsext_to_sel(
; CHECK-NEXT:    [[OR:%.*]] = select i1 %y, i32 -1, i32 %x
; CHECK-NEXT:    ret i32 [[OR]]
;
  %sext = sext i1 %y to i32
  %or = or i32 %sext, %x
  ret i32 %or
}

define i32 @orsext_to_sel_swap(i32 %x, i1 %y) {
; CHECK-LABEL: @orsext_to_sel_swap(
; CHECK-NEXT:    [[OR:%.*]] = select i1 %y, i32 -1, i32 %x
; CHECK-NEXT:    ret i32 [[OR]]
;
  %sext = sext i1 %y to i32
  %or = or i32 %x, %sext
  ret i32 %or
}

define i32 @orsext_to_sel_multi_use(i32 %x, i1 %y) {
; CHECK-LABEL: @orsext_to_sel_multi_use(
; CHECK-NEXT:    [[SEXT:%.*]] = sext i1 %y to i32
; CHECK-NEXT:    [[OR:%.*]] = or i32 [[SEXT]], %x
; CHECK-NEXT:    [[ADD:%.*]] = add i32 [[SEXT]], [[OR]]
; CHECK-NEXT:    ret i32 [[ADD]]
;
  %sext = sext i1 %y to i32
  %or = or i32 %sext, %x
  %add = add i32 %sext, %or
  ret i32 %add
}

define <2 x i32> @orsext_to_sel_vec(<2 x i32> %x, <2 x i1> %y) {
; CHECK-LABEL: @orsext_to_sel_vec(
; CHECK-NEXT:    [[OR:%.*]] = select <2 x i1> %y, <2 x i32> <i32 -1, i32 -1>, <2 x i32> %x
; CHECK-NEXT:    ret <2 x i32> [[OR]]
;
  %sext = sext <2 x i1> %y to <2 x i32>
  %or = or <2 x i32> %sext, %x
  ret <2 x i32> %or
}

define <2 x i132> @orsext_to_sel_vec_swap(<2 x i132> %x, <2 x i1> %y) {
; CHECK-LABEL: @orsext_to_sel_vec_swap(
; CHECK-NEXT:    [[OR:%.*]] = select <2 x i1> %y, <2 x i132> <i132 -1, i132 -1>, <2 x i132> %x
; CHECK-NEXT:    ret <2 x i132> [[OR]]
;
  %sext = sext <2 x i1> %y to <2 x i132>
  %or = or <2 x i132> %x, %sext
  ret <2 x i132> %or
}

define i32 @test39(i32 %a, i32 %b) {
; CHECK-LABEL: @test39(
; CHECK-NEXT:    [[OR:%.*]] = or i32 %a, %b
; CHECK-NEXT:    ret i32 [[OR]]
;
  %xor = xor i32 %a, -1
  %and = and i32 %xor, %b
  %or = or i32 %and, %a
  ret i32 %or
}

define i32 @test40(i32 %a, i32 %b) {
; CHECK-LABEL: @test40(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 %a, -1
; CHECK-NEXT:    [[OR:%.*]] = or i32 [[TMP1]], %b
; CHECK-NEXT:    ret i32 [[OR]]
;
  %and = and i32 %a, %b
  %xor = xor i32 %a, -1
  %or = or i32 %and, %xor
  ret i32 %or
}

define i32 @test41(i32 %a, i32 %b) {
; CHECK-LABEL: @test41(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 %a, -1
; CHECK-NEXT:    [[OR:%.*]] = xor i32 [[TMP1]], %b
; CHECK-NEXT:    ret i32 [[OR]]
;
  %and = and i32 %a, %b
  %nega = xor i32 %a, -1
  %xor = xor i32 %nega, %b
  %or = or i32 %and, %xor
  ret i32 %or
}

define i32 @test42(i32 %a, i32 %b) {
; CHECK-LABEL: @test42(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 %a, -1
; CHECK-NEXT:    [[OR:%.*]] = xor i32 [[TMP1]], %b
; CHECK-NEXT:    ret i32 [[OR]]
;
  %nega = xor i32 %a, -1
  %xor = xor i32 %nega, %b
  %and = and i32 %a, %b
  %or = or i32 %xor, %and
  ret i32 %or
}

define i32 @test43(i32 %a, i32 %b) {
; CHECK-LABEL: @test43(
; CHECK-NEXT:    [[OR:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    ret i32 [[OR]]
;
  %neg = xor i32 %b, -1
  %and = and i32 %a, %neg
  %xor = xor i32 %a, %b
  %or = or i32 %and, %xor
  ret i32 %or
}

define i32 @test44(i32 %a, i32 %b) {
; CHECK-LABEL: @test44(
; CHECK-NEXT:    [[OR:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    ret i32 [[OR]]
;
  %xor = xor i32 %a, %b
  %neg = xor i32 %b, -1
  %and = and i32 %a, %neg
  %or = or i32 %xor, %and
  ret i32 %or
}

define i32 @test45(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @test45(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %x, %z
; CHECK-NEXT:    [[OR1:%.*]] = or i32 [[TMP1]], %y
; CHECK-NEXT:    ret i32 [[OR1]]
;
  %or = or i32 %y, %z
  %and = and i32 %x, %or
  %or1 = or i32 %and, %y
  ret i32 %or1
}

define i1 @test46(i8 signext %c)  {
; CHECK-LABEL: @test46(
; CHECK-NEXT:    [[TMP1:%.*]] = and i8 %c, -33
; CHECK-NEXT:    [[TMP2:%.*]] = add i8 [[TMP1]], -65
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ult i8 [[TMP2]], 26
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %c.off = add i8 %c, -97
  %cmp1 = icmp ult i8 %c.off, 26
  %c.off17 = add i8 %c, -65
  %cmp2 = icmp ult i8 %c.off17, 26
  %or = or i1 %cmp1, %cmp2
  ret i1 %or
}

define i1 @test47(i8 signext %c)  {
; CHECK-LABEL: @test47(
; CHECK-NEXT:    [[TMP1:%.*]] = and i8 %c, -33
; CHECK-NEXT:    [[TMP2:%.*]] = add i8 [[TMP1]], -65
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ult i8 [[TMP2]], 27
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %c.off = add i8 %c, -65
  %cmp1 = icmp ule i8 %c.off, 26
  %c.off17 = add i8 %c, -97
  %cmp2 = icmp ule i8 %c.off17, 26
  %or = or i1 %cmp1, %cmp2
  ret i1 %or
}

define i1 @test48(i64 %x, i1 %b) {
; CHECK-LABEL: @test48(
; CHECK-NEXT:    ret i1 true
;
  %1 = icmp ult i64 %x, 2305843009213693952
  %2 = icmp ugt i64 %x, 2305843009213693951
  %.b = or i1 %2, %b
  %3 = or i1 %1, %.b
  ret i1 %3
}

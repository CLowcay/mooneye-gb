; This file is part of Mooneye GB.
; Copyright (C) 2014-2016 Joonas Javanainen <joonas.javanainen@gmail.com>
;
; Mooneye GB is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; Mooneye GB is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Mooneye GB.  If not, see <http://www.gnu.org/licenses/>.

; Tests how long does it take to get from STAT mode=1 interrupt to STAT mode=2 interrupt
; No sprites, scroll or window.

; Verified results:
;   pass: DMG, MGB, SGB, SGB2, CGB, AGB, AGS
;   fail: -

.incdir "../../common"
.include "common.s"

.macro clear_interrupts
  xor a
  ldh (<IF), a
.endm

.macro wait_mode ARGS mode
- ldh a, (<STAT)
  and $03
  cp mode
  jr nz, -
.endm

  di
  wait_vblank
  ld hl, STAT
  ld a, INTR_STAT
  ldh (<IE), a

.macro test_iter ARGS delay
  call setup_and_wait_mode2
  nops delay
  call setup_and_wait_mode0
.endm

  test_iter 4
  ld d, b
  test_iter 3
  ld e, b
  save_results
  assert_d $07
  assert_e $08
  jp process_results

setup_and_wait_mode2:
  wait_ly $42
  wait_mode $00
  wait_mode $03
  ld a, %00100000
  ldh (<STAT), a
  clear_interrupts
  ei

  halt
  nop
  jp fail_halt

setup_and_wait_mode0:
  ld a, %00001000
  ldh (<STAT), a
  clear_interrupts
  ei
  xor a
  ld b,a
- inc b
  jr -

fail_halt:
  test_failure_string "FAIL: HALT"

.org INTR_VEC_STAT
  add sp,+2
  ret

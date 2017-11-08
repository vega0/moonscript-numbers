--- Module that provides functions to convert numbers to any number systems.
-- All convert operations based on **tonumber** on 1/2 and determined in few steps
--	- Convert (any_based_number) to decimal
--	- Perform operation on decimals
--	- Convert result to any_based_number
--
--###Warning! Floats currently not supported!
--@author Nightmare0
--	email: seller.nightmares@gmail.com
--	discord: #4993
--@todo add floats support
--@module numbers

require "bit"

import band, rshift from bit
import floor from math
import insert, concat from table

import print, tonumber, assert, type, setmetatable, string, tostring, error, pairs from _G

module "numbers"

--debug = true

--- Convert decimal number to binary number.
--@function to_binary
--@tparam number num
--@tparam[opt] table accum Accumulator.
export to_binary = (num, accum = '') ->
	return '0' if num == 0
	while num > 0
		accum = (
			band(num, 1) > 0 and
				'1' or '0'
		) .. accum
		num = rshift num, 1
	accum

_Alphabet = {
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
	'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
	's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
}

--- Convert number to custom number system.
-- By default **num10** must be 10 based number only.
-- @function to_custom
-- @tparam number num10 Decimal number to convert.
-- @tparam number base Base number convert to.
-- @tparam[opt] table alphabet Alphabet for number system.
-- @tparam[opt] table accum Accumulator.
export to_custom = (num10, base, alphabet, accum = {}) ->
	unless alphabet
		alphabet = _Alphabet
	else
		while num10 ~= 0
			num10, r = floor(num10 / base), num10 % base
			r = alphabet[r]
			insert accum, 1, r

		return concat accum, ''

	if base > 10
		while num10 ~= 0
			num10, r = floor(num10 / base), num10 % base
			if r > 9
				r = alphabet[r - 9]
			insert accum, 1, r
	else
		while num10 ~= 0
			num10, r = floor(num10 / base), num10 % base
			insert accum, 1, r

	concat accum, ''

--- Class.Number
--@section Class

export class Number
	--- constructor
	--@usage
	--local obj
	-- -- initialize number with binary value
	-- obj = Number(1010011, 2) -- in this case number 1010011
	--                          -- is decimal but represented as binary.
	--                          -- if you need to setup long binary number, use string.
	-- obj = Number("0110001000010100010101011", 2)
	-- -- or as hex
	-- obj = Number (0xff, 16)
	--
	-- -- you can print its value, or change base of it.
	-- print (obj)
	-- obj:toBase(2) -- convert number to b internally.
	-- print(obj, obj:asBase(32))
	-- 
	-- -- output result of arithmetics with object.
	-- -- arithmetic results is Number objects.
	-- print(obj + 2, obj *2, obj - 2)
	--
	--
	--@tparam table self
	--@tparam number _number Initial number value.
	--@tparam[opt] number _base Base of this number, default = 10.
	new: (@_number, @_base = 10) =>
		--assert type(_number) == "number", "#1 must be number initial value."
		assert type(_base) == "number", "#2 must be number value."
		unless @asDecimal!
			error "Number ".._number.." has incorrect base (".._base..')!'

		if _base ~= 10 and type(_number) == "number"
			@_base = 10
			@toBase _base

	--- Get number as decimal.
	--@tparam table self
	--@treturn number
	asDecimal: => tonumber @_number, @_base

	--- Get number in different number system.
	-- Function dont modifying internal number values.
	--@tparam table self
	--@tparam number base Base of number system convert to.
	asBase: (base) =>
		switch base
			when 16 '%x'\format @asDecimal!
			when 10 @asDecimal!
			else
				to_custom @asDecimal!, base

	--- Convert number to another numbers system.
	-- Completely converts internal value repesentation without returning its result.
	--@tparam table self
	--@tparam number _base Number base.
	--@treturn table self
	toBase: (_base) =>
		assert type(_base) == "number", "#1 must be number value."
		@_base, @_number = _base, @asBase _base
		return @

	_prepare_op = (what) ->
		if type(what) == "table"
			what\asDecimal!
		else
			what

---Class.Number.metamethods
--@section meta

	--- tostring
	__tostring: =>
		@_number .. (@_base and '(' .. @_base .. ')' or '')


	--- Sum
	__add: (what) => Number(@asDecimal! + _prepare_op what)\toBase @_base

	--- Sub
	__sub: (what) => Number(@asDecimal! - _prepare_op what)\toBase @_base
--	__div: (what) => Number(@asDecimal! / _prepare_op what)\toBase @_base -- unsupported cuz no float support
--	__mul: (what) => Number(@asDecimal! * _prepare_op what)\toBase @_base -- unsupported too
	
	--- Pow
	__pow: (what) => Number(@asDecimal! ^ _prepare_op what)\toBase @_base

	__eq: (what) =>
		if @_base == what._base
			@_number == what._number
		else
			@asDecimal! == what\asDecimal!

if debug
	__test_case = ->
		-- sets of numbers
		bases = 32

		for {obj, num} in *[{Number(x^2)\toBase(x), x^2} for x = 2, bases]
			oDecimal = obj\asDecimal!
			assert (num == oDecimal), "Object "..tostring(obj).." is "..num.." not "..oDecimal
			print obj, ('dec->'					..obj\asDecimal!
				) .. (', hex->' 				.. obj\asBase(16)
				) .. (', max_base'..bases..'->'	..obj\asBase(bases)
				) .. (', bin->' 				.. obj\asBase 2)

			with sum = obj + 1337
				assert sum == Number(num + 1337)

			with sub = obj - 1
				assert sub\asDecimal! == num - 1

		--for num in *numberset
		--	print num, (num + 0xf), (num + 0xf)\asDecimal!

	__test_case!

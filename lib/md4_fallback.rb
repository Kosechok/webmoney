# lib/md4_fallback.rb
# Pure-Ruby MD4 fallback. If OpenSSL::Digest::MD4 available, it will be used,
# otherwise this implementation will be used via MD4Fallback::MD4Digest.
module MD4Fallback
  begin
    require "openssl"
    # Если OpenSSL поддерживает MD4 — используем его
    OpenSSL::Digest::MD4.new
    MD4Digest = OpenSSL::Digest::MD4
  rescue StandardError
    # Pure Ruby implementation (compatible with standard MD4 test vectors)
    class MD4Digest
      MASK = 0xffffffff

      def initialize
        reset
      end

      def reset
        @count = 0                  # bytes processed
        @buffer = "".b              # collected data blocks
        # initial state (little-endian words)
        @a = 0x67452301
        @b = 0xefcdab89
        @c = 0x98badcfe
        @d = 0x10325476
        self
      end

      def update(data)
        data = data.b
        @count += data.bytesize
        @buffer << data
        while @buffer.bytesize >= 64
          block = @buffer.slice!(0, 64)
          process_block(block)
        end
        self
      end
      alias << update

      # returns raw binary digest
      def digest
        # save state
        a, b, c, d = @a, @b, @c, @d
        count = @count
        buf = @buffer.dup

        # padding: 0x80 then zeros until 56 bytes mod 64, then 64-bit length (bits, little-endian)
        bit_len = (@count * 8) & 0xffffffffffffffff
        padding = "\x80".b
        pad_len = ((56 - (count + 1) % 64) % 64)
        padding << ("\x00".b * pad_len)
        padding << [bit_len & 0xffffffff, (bit_len >> 32) & 0xffffffff].pack("V2")

        update(padding)

        # after padding there should be a whole number of 64-byte blocks processed
        result = [@a & MASK, @b & MASK, @c & MASK, @d & MASK].pack("V4")

        # restore saved state so digest is non-destructive
        @a, @b, @c, @d = a, b, c, d
        @count = count
        @buffer = buf

        result
      end

      def hexdigest
        digest.unpack1("H*")
      end

      private

      def process_block(block)
        x = block.unpack("V16") # 16 little-endian 32-bit words
        aa, bb, cc, dd = @a, @b, @c, @d

        # Round 1
        aa = ff(aa, bb, cc, dd, x[0], 3)
        dd = ff(dd, aa, bb, cc, x[1], 7)
        cc = ff(cc, dd, aa, bb, x[2], 11)
        bb = ff(bb, cc, dd, aa, x[3], 19)
        aa = ff(aa, bb, cc, dd, x[4], 3)
        dd = ff(dd, aa, bb, cc, x[5], 7)
        cc = ff(cc, dd, aa, bb, x[6], 11)
        bb = ff(bb, cc, dd, aa, x[7], 19)
        aa = ff(aa, bb, cc, dd, x[8], 3)
        dd = ff(dd, aa, bb, cc, x[9], 7)
        cc = ff(cc, dd, aa, bb, x[10], 11)
        bb = ff(bb, cc, dd, aa, x[11], 19)
        aa = ff(aa, bb, cc, dd, x[12], 3)
        dd = ff(dd, aa, bb, cc, x[13], 7)
        cc = ff(cc, dd, aa, bb, x[14], 11)
        bb = ff(bb, cc, dd, aa, x[15], 19)

        # Round 2
        aa = gg(aa, bb, cc, dd, x[0], 3)
        dd = gg(dd, aa, bb, cc, x[4], 5)
        cc = gg(cc, dd, aa, bb, x[8], 9)
        bb = gg(bb, cc, dd, aa, x[12], 13)
        aa = gg(aa, bb, cc, dd, x[1], 3)
        dd = gg(dd, aa, bb, cc, x[5], 5)
        cc = gg(cc, dd, aa, bb, x[9], 9)
        bb = gg(bb, cc, dd, aa, x[13], 13)
        aa = gg(aa, bb, cc, dd, x[2], 3)
        dd = gg(dd, aa, bb, cc, x[6], 5)
        cc = gg(cc, dd, aa, bb, x[10], 9)
        bb = gg(bb, cc, dd, aa, x[14], 13)
        aa = gg(aa, bb, cc, dd, x[3], 3)
        dd = gg(dd, aa, bb, cc, x[7], 5)
        cc = gg(cc, dd, aa, bb, x[11], 9)
        bb = gg(bb, cc, dd, aa, x[15], 13)

        # Round 3
        aa = hh(aa, bb, cc, dd, x[0], 3)
        dd = hh(dd, aa, bb, cc, x[8], 9)
        cc = hh(cc, dd, aa, bb, x[4], 11)
        bb = hh(bb, cc, dd, aa, x[12], 15)
        aa = hh(aa, bb, cc, dd, x[2], 3)
        dd = hh(dd, aa, bb, cc, x[10], 9)
        cc = hh(cc, dd, aa, bb, x[6], 11)
        bb = hh(bb, cc, dd, aa, x[14], 15)
        aa = hh(aa, bb, cc, dd, x[1], 3)
        dd = hh(dd, aa, bb, cc, x[9], 9)
        cc = hh(cc, dd, aa, bb, x[5], 11)
        bb = hh(bb, cc, dd, aa, x[13], 15)
        aa = hh(aa, bb, cc, dd, x[3], 3)
        dd = hh(dd, aa, bb, cc, x[11], 9)
        cc = hh(cc, dd, aa, bb, x[7], 11)
        bb = hh(bb, cc, dd, aa, x[15], 15)

        @a = (@a + aa) & MASK
        @b = (@b + bb) & MASK
        @c = (@c + cc) & MASK
        @d = (@d + dd) & MASK
      end

      def f(x, y, z)
        (x & y) | (~x & z)
      end

      def g(x, y, z)
        (x & y) | (x & z) | (y & z)
      end

      def h(x, y, z)
        x ^ y ^ z
      end

      def rotl(x, n)
        ((x << n) | (x >> (32 - n))) & MASK
      end

      def ff(a, b, c, d, xk, s)
        rotl((a + f(b, c, d) + xk) & MASK, s)
      end

      def gg(a, b, c, d, xk, s)
        rotl((a + g(b, c, d) + xk + 0x5a827999) & MASK, s)
      end

      def hh(a, b, c, d, xk, s)
        rotl((a + h(b, c, d) + xk + 0x6ed9eba1) & MASK, s)
      end
    end
  end
end


# encoding: binary
module Crypto
  # NaCl's base point (a.k.a. standard group element), serialized as hex
  STANDARD_GROUP_ELEMENT = ["0900000000000000000000000000000000000000000000000000000000000000"].pack("H*").freeze

  # Order of the standard group
  STANDARD_GROUP_ORDER = 2**252 + 27742317777372353535851937790883648493

  # Points provide the interface to NaCl's Curve25519 high-speed elliptic
  # curve cryptography, which can be used for implementing Diffie-Hellman
  # and other forms of public key cryptography (e.g. Crypto::Box)
  #
  # Objects of the Point class represent points on Edwards curves. NaCl
  # defines a base point (the "standard group element") which we can
  # multiply by an arbitrary integer. This is how NaCl computes public
  # keys from private keys.
  class Point
    include KeyComparator
    include Serializable

    # Number of bytes in a scalar on this curve
    SCALARBYTES = NaCl::ED25519_SCALARBYTES

    # Creates a new Point from the given serialization
    #
    # @param [String] point location of a group element (32-bytes)
    #
    # @return [Crypto::Point] the Point at this location
    def initialize(point)
      @point = point.to_str

      # FIXME: really should have a separate constant here for group element size
      # Group elements and scalars are both 32-bits, but that's for convenience
      Util.check_length(@point, SCALARBYTES, "group element")
    end

    # Multiply the given integer by this point
    # This ordering is a bit confusing because traditionally the point
    # would be the right-hand operand.
    #
    # @param [String] integer value to multiply with this Point (32-bytes)
    #
    # @return [Crypto::Point] result as a Point object
    def mult(integer, encoding = :raw)
      integer = integer.to_str
      Util.check_length(integer, SCALARBYTES, "integer")

      result = Util.zeros(SCALARBYTES)
      NaCl.crypto_scalarmult_curve25519(result, integer, @point)

      self.class.new(result)
    end

    # Return the point serialized as bytes
    #
    # @return [String] 32-byte string representing this point
    def to_bytes; @point; end

    @base_point = Point.new(STANDARD_GROUP_ELEMENT)

    # NaCl's standard base point for all Curve25519 public keys
    #
    # @return [Crypto::Point] standard base point (a.k.a. standard group element)
    def self.base; @base_point; end
    def self.base_point; @base_point; end
  end
end
   

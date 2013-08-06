module Kernel
  def in(ary)
    index = 0
    ary.each { |e| self == e ? break : index += 1 }
    if index == ary.length
      return false
    else
      return index
    end
  end
end
module Dryad
  class DryadError < RuntimeError
  end

  class MultipleIdsError < DryadError
  end

  class WritingOutOfContextError < DryadError
  end

  class NoSuchContentBlock < DryadError
  end

  # You've found a bug if you get one of these; they indicate something went wrong inside Dryad
  class InternalError < DryadError
  end
end

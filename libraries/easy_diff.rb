# Easy Diff: Recursive diff, merge, and unmerge for hashes and arrays
# https://github.com/Blargel/easy_diff
# Copyright (c) 2011 Abner Qian
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module EasyDiff
  module SafeDup
    def safe_dup
      begin
        self.dup
      rescue TypeError
        self
      end
    end
  end
end

module EasyDiff
  module Core
    def self.easy_diff(original, modified)
      removed = nil
      added   = nil

      if original.nil?
        added = modified.safe_dup
      elsif modified.nil?
        removed = original.safe_dup
      elsif original.is_a?(Hash) && modified.is_a?(Hash)
        removed = {}
        added   = {}
        original_keys   = original.keys
        modified_keys   = modified.keys
        keys_in_common  = original_keys & modified_keys
        keys_removed    = original_keys - modified_keys
        keys_added      = modified_keys - original_keys
        keys_removed.each{ |key| removed[key] = original[key].safe_dup }
        keys_added.each{ |key| added[key] = modified[key].safe_dup }
        keys_in_common.each do |key|
          r, a = easy_diff original[key], modified[key]
          removed[key] = r unless r.nil?
          added[key] = a unless a.nil?
        end
      elsif original.is_a?(Array) && modified.is_a?(Array)
        removed = original - modified
        added   = modified - original
      elsif original != modified
        removed   = original
        added     = modified
      end
      return removed, added
    end

    def self.easy_unmerge!(original, removed)
      if original.is_a?(Hash) && removed.is_a?(Hash)
        original_keys  = original.keys
        removed_keys   = removed.keys
        keys_in_common = original_keys & removed_keys
        keys_in_common.each{ |key| original.delete(key) if easy_unmerge!(original[key], removed[key]).nil? }
      elsif original.is_a?(Array) && removed.is_a?(Array)
        original.reject!{ |e| removed.include?(e) }
        original.sort!
      elsif original == removed
        original = nil
      end
      original
    end

    def self.easy_merge!(original, added)
      if added.nil?
        return original
      elsif original.is_a?(Hash) && added.is_a?(Hash)
        added_keys = added.keys
        added_keys.each{ |key| original[key] = easy_merge!(original[key], added[key])}
      elsif original.is_a?(Array) && added.is_a?(Array)
        original |=  added
        original.sort!
      else
        original = added.safe_dup
      end
      original
    end

    def self.easy_clone(original)
      Marshal::load(Marshal.dump(original))
    end
  end
end

module EasyDiff
  module HashExt
    def easy_diff(other)
      EasyDiff::Core.easy_diff self, other
    end

    def easy_merge!(other)
      EasyDiff::Core.easy_merge! self, other
    end

    def easy_unmerge!(other)
      EasyDiff::Core.easy_unmerge! self, other
    end

    def easy_merge(other)
      self.easy_clone.easy_merge!(other)
    end

    def easy_unmerge(other)
      self.easy_clone.easy_unmerge!(other)
    end

    def easy_clone
      EasyDiff::Core.easy_clone self
    end
  end
end

Object.send :include, EasyDiff::SafeDup
Hash.send :include, EasyDiff::HashExt

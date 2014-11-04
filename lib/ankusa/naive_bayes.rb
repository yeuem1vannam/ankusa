module Ankusa
  INFTY = 1.0 / 0.0

  class NaiveBayesClassifier
    include Classifier

    def hash_classify(word_hash, classes = nil)
      # return the most probable class

      result = hash_log_likelihoods(word_hash, classes)
      if result.values.uniq.size. === 1
        # unless all classes are equally likely, then return nil
        return nil
      else
        result.sort_by { |c| -c[1] }.first.first
      end
    end

    def classify(text, classes=nil)
      # return the most probable class

      result = log_likelihoods(text, classes)
      if result.values.uniq.size. === 1
        # unless all classes are equally likely, then return nil
        return nil
      else
        result.sort_by { |c| -c[1] }.first.first
      end
    end

    # Classes is an array of classes to look at
    def classifications(text, classnames=nil)
      result = log_likelihoods text, classnames
      result.keys.each { |k|
        result[k] = (result[k] == -INFTY) ? 0 : Math.exp(result[k])
      }

      # normalize to get probs
      sum = result.values.inject{ |x,y| x+y }
      result.keys.each { |k|
        result[k] = result[k] / sum
        } unless sum.zero?
      result
    end

    # Classes is an array of classes to look at
    def log_likelihoods(text, classnames=nil)
      classnames ||= @classnames
      result = Hash.new 0

      TextHash.new(text).each { |word, count|
        probs = get_word_probs(word, classnames)
        classnames.each { |k|
          # Choose a really small probability if the word has never been seen before in class k
          result[k] += Math.log(probs[k] > 0 ? (probs[k] * count) : Float::EPSILON)
        }
      }

      # add the prior
      doc_counts = doc_count_totals.select { |k,v| classnames.include? k }.map { |k,v| v }

      doc_count_total = (doc_counts.inject(0){ |x,y| x+y } + classnames.length).to_f

      classnames.each { |k|
        result[k] += Math.log((@storage.get_doc_count(k) + 1).to_f / doc_count_total)
      }

      result
    end

    def hash_log_likelihoods(word_hash, classnames = nil)
      classnames ||= @classnames
      result = Hash.new 0

      word_hash.each { |word, count|
        probs = get_word_probs(word, classnames)
        classnames.each { |k|
          # Choose a really small probability if the word has never been seen before in class k
          result[k] += Math.log(probs[k] > 0 ? (probs[k] * count) : Float::EPSILON)
        }
      }

      # add the prior
      doc_counts = doc_count_totals.select { |k,v| classnames.include? k }.map { |k,v| v }

      doc_count_total = (doc_counts.inject(0){ |x,y| x+y } + classnames.length).to_f

      classnames.each { |k|
        result[k] += Math.log((@storage.get_doc_count(k) + 1).to_f / doc_count_total)
      }

      result
    end

  end

end

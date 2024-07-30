class Tokenizer
    def initialize(str)
        @str = str
        @tokens = []
    end

    def tokenize
        @str.split.each do |word|
            @tokens << word
        end
        @tokens
    end
end
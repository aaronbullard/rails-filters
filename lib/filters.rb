module Filters
  class Filters

    OPERATORS = ['==', '!=', '>=<', '>=', '<=', '><', '>', '<'] #order matters here!
    SEMICOLON = '\;'
    COMMA = '\,'
    BACKSLASH = '\\'

    def initialize(params)
      @params = params
      @filters = []

      # only execute if it looks like filters...
      if !params.nil? and ['<', '>', '='].any? { |oper| params.include?(oper) }
        @filters = parse()
      end
    end

    def get(field = nil)
      if field != nil
        @filters.each do |filter|
          if filter[:field] == field
            return filter
          end
        end
        return nil
      end

      return @filters
    end

    def has?(field)
      return !get(field).nil?
    end

    def to_sql(filter)
      templates = {
        '==' => "#{filter[:field]} = '#{filter[:value]}'",
        '!=' => "#{filter[:field]} != '#{filter[:value]}'",
        '>=' => "#{filter[:field]} >= '#{filter[:value]}'",
        '<=' => "#{filter[:field]} <= '#{filter[:value]}'",
        '>=<' => "#{filter[:field]} BETWEEN '#{filter[:value][0]}' AND '#{filter[:value][1]}'",
        '><' => "#{filter[:field]} > '#{filter[:value][0]}' AND #{filter[:field]} < '#{filter[:value][1]}'",
        '>' => "#{filter[:field]} > '#{filter[:value]}'",
        '<' => "#{filter[:field]} < '#{filter[:value]}'"
      }

      filter[:sql] = templates[filter[:operator]]
      filter[:sql]["'NULL'"] = "NULL" if filter[:value] == 'NULL'
      return filter
    end

    def to_safe_sql(filter)
      templates = {
        '==' => "#{filter[:field]} = ?",
        '!=' => "#{filter[:field]} != ?",
        '>=' => "#{filter[:field]} >= ?",
        '<=' => "#{filter[:field]} <= ?",
        '>=<' => "#{filter[:field]} BETWEEN ? AND ?",
        '><' => "#{filter[:field]} > ? AND #{filter[:field]} < ?",
        '>' => "#{filter[:field]} > ?",
        '<' => "#{filter[:field]} < ?"
      }

      filter[:safe_sql] = templates[filter[:operator]]
      filter[:bindings] = filter[:value].kind_of?(Array) ? filter[:value] : [filter[:value]]

      filter = fix_null_queries(filter) if filter[:value] == 'NULL'

      filter
    end

    private

    def parse
      string = @params
      string.gsub! SEMICOLON, 'SEMICOLON'
      string.gsub! COMMA, 'COMMA'
      string.gsub! BACKSLASH, 'BACKSLASH'

      return string
              .split(',')
              .map { |filter_string| split_segments(filter_string) }
              .map { |filter| handle_compounds(filter) }
              .map { |filter| replace_escaped_characters(filter) }
              .map { |filter| to_sql(filter) }
              .map { |filter| to_safe_sql(filter) }

    end

    def split_segments(filter_string)
      filter = nil
      OPERATORS.each do |oper|
        if filter_string.include? oper
          segments = filter_string.split(oper)
          filter = {
            field: segments[0],
            operator: oper,
            value: segments[1]
          }
          break
        end
      end

      filter
    end

    def handle_compounds(filter)
      if ['><', '>=<'].include? filter[:operator]
        filter[:value] = filter[:value].split(';')
      end

      filter
    end

    def replace_escaped_characters(filter)
      string = filter[:value]

      # skip if array
      if string.kind_of?(Array)
        return filter
      end

      string.gsub! 'SEMICOLON', SEMICOLON
      string.gsub! 'COMMA', COMMA
      string.gsub! 'BACKSLASH', BACKSLASH
      filter[:value] = string

      return filter
    end

    def fix_null_queries(filter)
        if filter[:operator] == '=='
            filter[:safe_sql] = "#{filter[:field]} IS NULL"
        end
        if filter[:operator] == '!='
            filter[:safe_sql] = "#{filter[:field]} IS NOT NULL"
        end

        filter[:bindings] = []
        filter
    end

  end # end Filter
end

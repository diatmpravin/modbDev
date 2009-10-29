class Ruport::Data::Table
  def average(column)
    count = non_zero_row_count(column)
    if(count > 0)
      sum(column) / count.to_f
    else
      0
    end
  end

  protected

  def non_zero_row_count(column)
    self.inject(0) do |memo, row|
      memo += 1 if row[column] && row[column] > 0
      memo
    end
  end

end

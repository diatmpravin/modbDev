class Ruport::Data::Table
  def average(column)
    if(self.size > 0)
      sum(column) / self.size.to_f
    else
      0
    end
  end
end

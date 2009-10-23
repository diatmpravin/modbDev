class Ruport::Data::Table
  def average(column)
    sum(column) / self.size.to_f
  end
end

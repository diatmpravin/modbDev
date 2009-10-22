class Ruport::Data::Table
  def average(column)
    sum(column) / self.size
  end
end

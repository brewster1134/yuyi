describe Hash do
  describe '#tsort' do
    it 'should topological sort' do
      expect({1=>[2, 3], 2=>[3], 3=>[]}.tsort).to eq [3, 2, 1]
    end
  end
end

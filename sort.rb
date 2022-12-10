require_relative 'quicksort'
require_relative 'parallel_quicksort'
require 'thread/pool'

class Sort
  include Concurrent::Async
  @q = QuickSort.new
  @pq = ParallelQuickSort.new

  def self.sort
    names_array = []
    File.readlines("names.txt").map do |line|
      names_array.push(line)
    end

    seq_names_hashlist = []
    names_array.each do |name|
      first_name, last_name = name.split
      seq_names_hashlist.push( {first_name: first_name, last_name: last_name, full_name: name.strip} )
    end

    seq_time_start = Time.now
    @q.quicksort(seq_names_hashlist, 0, seq_names_hashlist.length-1, "last_name")
    # first_name_sort(seq_names_hashlist)
    seq_time_end = Time.now

    seq_runtime = seq_time_end - seq_time_start
    puts("Sequential runtime is #{seq_runtime}")

    File.open("sequential_sort.txt", "w+") do |file|
      seq_names_hashlist.each do |line|
        full_name = line[:full_name]
        file.puts(full_name)
      end
    end

    par_names_hashlist = []
    names_array.each do |name|
      first_name, last_name = name.split
      par_names_hashlist.push( {first_name: first_name, last_name: last_name, full_name: name.strip} )
    end

    par_time_start = Time.now
    @pq.quicksort(par_names_hashlist, 0, par_names_hashlist.length - 1, "last_name")
    # first_name_sort(par_names_hashlist)
    par_time_end = Time.now

    par_runtime = par_time_end - par_time_start
    puts("Parallel runtime is #{par_runtime}")

    File.open("parallel_sort.txt", "w+") do |file|
      par_names_hashlist.each do |line|
        full_name = line[:full_name]
        file.puts(full_name)
      end
    end

    if seq_names_hashlist == par_names_hashlist
      puts("Sequential output is the same as Parallel")
    else
      puts("Outputs don't match")
    end
  end

  def self.first_name_sort(last_name_sorted_hash)
    sort_start = 0
    same_last_name_count = 0

    last_name_sorted_hash.each_with_index do |hash_line, i|
      return last_name_sorted_hash if i == last_name_sorted_hash.length-1
      next_hash_line = last_name_sorted_hash[i+1][:last_name]

      if next_hash_line == hash_line[:last_name]
        same_last_name_count += 1
      else
        @q.quicksort(last_name_sorted_hash, sort_start, sort_start + same_last_name_count, "first_name")
        sort_start = same_last_name_count
        same_last_name_count = 0
      end
    end
  end
end
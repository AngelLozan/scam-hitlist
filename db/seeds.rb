require "csv"

puts "Populating Domain Host/Registrar list.."

CSV.foreach(Rails.root.join("lib/hosts.csv"), headers: :first_row) do |row|
  host = Host.create({
    name: row["name"],
    email: row["email"],
  })

  puts "created #{host}"
end

puts "Created Hosts, now populating form lsit..."

CSV.foreach(Rails.root.join("lib/forms.csv"), headers: :first_row) do |row|
  form = Form.create({
    name: row["name"],
    url: row["url"],
  })

  puts "created #{form}"
end

puts "creating IOCs, this can take a moment ..."

CSV.foreach(Rails.root.join("lib/data.csv"), headers: :first_row) do |row|
  ioc = Ioc.create({
    id: row["id"],
    url: row["url"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
    removed_date: row["removed_date"],
    status: row["status"],
    report_method_one: row["report_method_one"],
    report_method_two: row["report_method_two"],
    form: row["form"],
    host: row["host"],
    follow_up_date: row["follow_up_date"],
    follow_up_count: row["follow_up_count"],
    comments: row["comments"],
  })

  puts "created #{ioc}"
end

puts "created all models"

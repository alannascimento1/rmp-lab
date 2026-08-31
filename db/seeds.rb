# Volume de dados grande o bastante para que os problemas de performance
# aparecam em milissegundos visiveis no painel do profiler.
#
#   bin/rails db:seed
#
# Usa insert_all (SQL bruto, sem instanciar models) para semear rapido.

USERS    = 400
POSTS    = 40_000
COMMENTS = 80_000

now = Time.current

puts "limpando..."
[ PostTag, Comment, Post, Tag, User ].each { |m| m.delete_all }

puts "criando #{USERS} usuarios..."
first_names = %w[Ana Bruno Carla Diego Elisa Fabio Gabi Heitor Iara Joao Karina Lucas Marina Nuno Olivia Paulo Rita Sergio Tania Vitor]
food_names  = %w[Morango Uva Caju Abacaxi Goiaba Melancia Manga Banana Laranja Limao Abacate Ameixa Cereja Figo Kiwi Pera Pessego Framboesa Amora Melao]

users = Array.new(USERS) do |i|
  # 20 nomes x 20 comidas = 400 combinacoes unicas ("Joao Caju")
  name = "#{first_names[i % first_names.size]} #{food_names[(i / first_names.size) % food_names.size]}"
  { name: name, email: "user#{i + 1}@example.com", bio: "Perfil de teste numero #{i + 1}.",
    posts_count: 0, created_at: now, updated_at: now }
end
User.insert_all(users)
user_ids = User.pluck(:id)

puts "criando #{Tag.count.zero? ? 12 : 0} tags..."
tag_names = %w[rails performance sql cache ruby profiling views n+1 indices postgres deploy testes]
Tag.insert_all(tag_names.map { |n| { name: n, created_at: now, updated_at: now } })
tag_ids = Tag.pluck(:id)

puts "criando #{POSTS} posts..."
topics = [ "Como medir", "Um estudo sobre", "Notas rapidas de", "O guia pratico de", "Armadilhas comuns em" ]
subjects = [ "N+1 queries", "cache de fragmento", "indices compostos", "render de collection",
             "alocacao de objetos", "conexoes de banco", "background jobs", "serializacao JSON" ]

POSTS.times.each_slice(2_000) do |slice|
  rows = slice.map do |i|
    code = "PST-#{format('%06d', i + 1)}"
    { user_id: user_ids[i % user_ids.size],
      title: "#{topics[i % topics.size]} #{subjects[i % subjects.size]} ##{i + 1}",
      body: "Corpo do post numero #{i + 1}. " * 12,
      comments_count: 0,
      views_count: (i * 7) % 5_000,
      published_at: now - i.minutes,
      code: code,          # coluna indexada
      legacy_code: code,   # mesmo valor, sem indice
      created_at: now, updated_at: now }
  end
  Post.insert_all(rows)
  print "."
end
puts
post_ids = Post.pluck(:id)

puts "criando #{COMMENTS} comentarios..."
COMMENTS.times.each_slice(5_000) do |slice|
  rows = slice.map do |i|
    { post_id: post_ids[(i * 13) % post_ids.size],
      user_id: user_ids[(i * 7) % user_ids.size],
      body: "Comentario #{i + 1}: faz sentido, mas ja' mediu antes de otimizar?",
      created_at: now - i.seconds, updated_at: now - i.seconds }
  end
  Comment.insert_all(rows)
  print "."
end
puts

puts "ligando tags aos posts..."
post_tag_rows = post_ids.first(4_000).flat_map.with_index do |pid, i|
  [ { post_id: pid, tag_id: tag_ids[i % tag_ids.size] },
    { post_id: pid, tag_id: tag_ids[(i + 3) % tag_ids.size] } ]
end
PostTag.insert_all(post_tag_rows)

puts "recalculando counter caches..."
ActiveRecord::Base.connection.execute(<<~SQL)
  UPDATE posts SET comments_count =
    (SELECT COUNT(*) FROM comments WHERE comments.post_id = posts.id)
SQL
ActiveRecord::Base.connection.execute(<<~SQL)
  UPDATE users SET posts_count =
    (SELECT COUNT(*) FROM posts WHERE posts.user_id = users.id)
SQL

puts "pronto: #{User.count} usuarios, #{Post.count} posts, #{Comment.count} comentarios."

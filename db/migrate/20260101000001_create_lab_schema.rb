class CreateLabSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string  :name,        null: false
      t.string  :email,       null: false
      t.text    :bio
      t.integer :posts_count, null: false, default: 0
      t.timestamps
    end

    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :title, null: false
      t.text    :body
      t.integer :comments_count, null: false, default: 0
      t.integer :views_count,    null: false, default: 0
      t.datetime :published_at

      # Duas colunas com o MESMO conteudo. A unica diferenca e' o indice.
      # Serve para comparar full table scan x index lookup no painel de SQL.
      t.string :code         # indexado abaixo
      t.string :legacy_code  # sem indice, de proposito
      t.timestamps
    end
    add_index :posts, :code

    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end

    create_table :tags do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :tags, :name, unique: true

    create_table :post_tags do |t|
      t.references :post, null: false, foreign_key: true
      t.references :tag,  null: false, foreign_key: true
    end
  end
end

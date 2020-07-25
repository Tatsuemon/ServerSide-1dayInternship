class PeopleController < ApplicationController
  def index
    query = params[:query]
    if query.present?
      @people = Person.has_like(query).all()
      return
    end
    @people = Person.includes(:cards).all()

  end

  def merge
    ActiveRecord::Base.transaction do
      @cards = Card.all()

      name_emails = {} # key: {name, email}, value: list(person_id)

      # 表記揺れの修正
      @cards.each do |card|
        card = card.fix_name()
        name_emails[[card.name, card.email]] = name_emails[[card.name, card.email]].present? ? name_emails[[card.name, card.email]].append(card.person_id) : [card.person_id]
      end

      delete_person_ids = []

      # MARK: emailとnameが完全一致
      name_emails.each do |key, value|
        person_ids = value.uniq
        if person_ids.size() > 1
          update_cards(person_ids, {
            person_id: person_ids[0],
            name: key[0],
            email: key[1]
          })
          delete_person_ids += person_ids[1..]
        end
      end

      @cards.reload

      # MARK: 名前が完全一致 & 職業関連度が80%以上である
      name_persons = {} # key: name, value: list(person_id)
      person_titles = {}  # key; person_id, value: list(titles)
      @cards.each do |card|
        titles = person_titles.fetch(card.person_id, [])
        unless titles.include?(card.title)
          titles.append(card.title)
          person_titles[card.person_id] = titles
        end

        name_person = name_persons.fetch(card.name, [])

        unless name_person.include?(card.person_id)
          person_ids = name_person
          person_ids.append(card.person_id)
          name_persons[card.name] = person_ids
        end
      end

      name_persons.each do |key, value|
        if value.size() > 1
          # 残すperson_idをkey, person_idを結合していく
          update_person_ids = {}
          value.each do |key1|
            value.each do |key2|
              unless key1==key2
                ok = calc_titles(person_titles.fetch(key1, []), person_titles.fetch(key2, []))
                if ok
                  min_key = [key1, key2].min()
                  max_key = [key1, key2].max()
                  if update_person_ids.has_key?(min_key)
                    update_person_ids[min_key].append(max_key)
                  else
                    update_person_ids[min_key] = [max_key]
                    update_person_ids[max_key] = []
                  end
                end
              end
            end
          end

          update_person_ids.each do |key, value|
            # update処理とdelete_person_idの追加
            update_cards(value, {
              person_id: key
            })
            delete_person_ids += value
          end
        end
      end

      # 重複したものの削除
      delete_person_ids.uniq!
      if delete_person_ids.present?
        delete_peoples(delete_person_ids)
      end

      redirect_to root_path
    rescue => error
      print(error)
      redirect_to root_path
    end
  end

  private
  def delete_peoples(person_ids)
    peoples = Person.where(id: person_ids).all()
    peoples.delete_all
  end

  def update_cards(person_ids, params)
    cards = Card.where(person_id: person_ids).all()
    cards.update_all(params)
  end

  def calc_titles(titles_a, titles_b)
    return false if titles_a.size()==0 or titles_b.size()==0

    titles_a.each do |title_a|
      titles_b.each do |title_b|
        return true if Card.calc(title_a, title_b) >= 80
      end

      return false
    end
  end
end
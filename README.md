Movie Mate – Kullanıcı Geçmişine Dayalı Yapay Zeka Destekli Film Öneri ve Sosyal Paylaşım Uygulaması
Filmlerim, kullanıcıların izleme geçmişine ve beğenilerine göre yapay zeka destekli kişiselleştirilmiş film önerileri sunan, sosyal etkileşim özellikleriyle zenginleştirilmiş bir mobil uygulamadır. Kaggle’dan alınan ve düzenlenen 1000 adetlik film verisi Firebase veritabanına entegre edilerek güçlü bir içerik altyapısı oluşturulmuştur.

Kullanıcılar uygulama üzerinden film listelerini görüntüleyebilir, izledikleri ve beğendikleri filmleri işaretleyebilir, filmler hakkında yorum yapabilir ve diğer kullanıcıların yorumlarını görebilirler. Yorum yapan kişilerin profilleri ziyaret edilerek onların izlediği filmler incelenebilir. Ayrıca kullanıcılar birbirlerini takip edebilir, bu sayede film odaklı bir sosyal ağ deneyimi yaşayabilirler.

📌 Yapay Zeka Destekli Öneri Sistemi
Filmlerim uygulamasındaki öneri sistemi, kullanıcı etkileşimini analiz ederek kişiye özel film listeleri sunar. Kullanıcı öneri sayfasını açtığında, izleme geçmişine ait veriler uzak bir Python sunucusuna gönderilir. Python tarafında bu veriler makine öğrenmesi teknikleri ile işlenir, kullanıcıya özel önerilen filmler listesi oluşturulur ve bu liste mobil uygulamaya geri gönderilir. Gelen öneriler anlık olarak liste içerisinde görsel olarak sunulur. Tüm bu işlemler uygulama içinde yalnızca öneri sayfasının açılmasıyla otomatik olarak gerçekleştirilir; kullanıcının ekstra bir işlem yapmasına gerek yoktur.

Filmlerim, sade ve kullanıcı dostu arayüzü ile kolay kullanım sunarken, yapay zeka destekli altyapısı sayesinde her kullanıcıya özel önerilerle kişiselleştirilmiş bir deneyim sunar. Modern Swift arayüzü ile geliştirilen uygulama, Firebase altyapısı sayesinde gerçek zamanlı veri akışı ve güvenli kullanıcı yönetimi sağlar.

Sosyal etkileşim, kişisel profil oluşturma, yorumlara geri bildirim ve takip sistemi gibi özellikleriyle kullanıcılar sadece film keşfetmekle kalmaz, aynı zamanda etkileşimde bulunarak bir sinema topluluğunun parçası olurlar.

Filmlerim, klasik film listesi uygulamalarının ötesine geçerek, öneri sistemini kişiselleştirme ve sosyal paylaşımla birleştiren güçlü bir mobil platformdur.

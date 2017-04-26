wget http://www.musicxml.org/dtds/attributes.mod
wget http://www.musicxml.org/dtds/barline.mod
wget http://www.musicxml.org/dtds/basecamp.mei
wget http://www.musicxml.org/dtds/basecamp-time.xml
wget http://www.musicxml.org/dtds/basecamp.xml
wget http://www.musicxml.org/dtds/common.mod
wget http://www.musicxml.org/dtds/direction.mod
wget http://www.musicxml.org/dtds/identity.mod
wget http://www.musicxml.org/dtds/isolat1.ent
wget http://www.musicxml.org/dtds/isolat2.ent
wget http://www.musicxml.org/dtds/layout.mod
wget http://www.musicxml.org/dtds/link.mod
wget http://www.musicxml.org/dtds/note.mod
wget http://www.musicxml.org/dtds/parttime.xsl
wget http://www.musicxml.org/dtds/partwise.dtd
wget http://www.musicxml.org/dtds/score.mod
wget http://www.musicxml.org/dtds/timewise.dtd

edit to local file dtd path

sed -ie 's/http:\/\/www.musicxml.org\/dtds\///g' basecamp.xml

saxonb-xslt -s:basecamp.xml -xsl:parttime.xsl -o:basecamp-time.xml

edit to local file dtd path

saxonb-xslt -s:basecamp-time.xml -xsl:musicxml2mei-3.0.xsl -o:basecamp.mei

bug:

Error on line 2611 of musicxml2mei-3.0.xsl:
  XPTY0004: A sequence of more than one item is not allowed as the first argument of
  normalize-space() ("G", "F") 
  at xsl:for-each (file:/vagrant/meitools/musicxml2mei-3.0.xsl#2593)
     processing /staffDef
  at xsl:for-each (file:/vagrant/meitools/musicxml2mei-3.0.xsl#2239)
     processing /score-timewise/measure[8]/part[1]
  at xsl:apply-templates (file:/vagrant/meitools/musicxml2mei-3.0.xsl#7792)
     processing /score-timewise/measure[8]
  at xsl:apply-templates (file:/vagrant/meitools/musicxml2mei-3.0.xsl#372)
     processing /score-timewise
Transformation failed: Run-time errors were reported


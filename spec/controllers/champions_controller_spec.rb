require 'rails_helper'

describe ChampionsController, type: :controller do
  let(:resources) do
    JSON.parse(File.read('api.json')).with_indifferent_access[:resources]
  end
  let(:params) do
    res = resources.detect do |res|
      res[:name] == "champions/#{action}"
    end
    JSON.parse(res[:body][:text])
  end

  def speech
    JSON.parse(response.body).with_indifferent_access[:speech]
  end

  describe 'POST title' do
    let(:action) { :title }

    it 'should return the champions title' do
      post action, params
      expect(speech).to eq "Sona's title is Maven of the Strings"
    end
  end

  describe 'POST build' do
    let(:action) { :build }

    context 'when valid' do
      it 'should provide a build for a champion' do
        post action, params
        expect(speech).to eq "The highest win rate build for Bard Support is Boots of Mobility, Sightstone, Frost Queen's Claim, Redemption, Knight's Vow, Locket of the Iron Solari"
      end
    end

    context 'when invalid' do
      it 'should return the do not play response' do
        champion_params = params['result']['parameters']
        champion_params['lane'] = 'Top'

        post action, params
        expect(speech).to eq controller.send(
          :do_not_play_response,
          champion_params['champion'],
          champion_params['lane']
        )[:speech]
      end
    end
  end

  describe 'POST ability_order' do
    let(:action) { :ability_order }

    context 'when valid' do
      it 'should return the first order and max order for abilities' do
        post action, params
        expect(speech).to eq(
        "There is no recommended way to play Leblanc as Jungle. Please do not\nmake your team surrender at 20.\n"
        )
      end
    end

    context 'when invalid' do
      it 'should return the do not play response' do
        champion_params = params['result']['parameters']
        champion_params['lane'] = 'Support'

        post action, params
        expect(speech).to eq controller.send(
          :do_not_play_response,
          champion_params['champion'],
          champion_params['lane']
        )[:speech]
      end
    end
  end

  describe 'POST matchup' do
    let(:action) { :matchup }

    context 'when valid' do
      it 'should return the best counters for the champion' do
        post action, params
        expect(speech).to eq(
          "The best counters for Jayce Top are JarvanIV at 58.19% win rate, Sion at 56.3% win rate, Nautilus at 60.3% win rate"
        )
      end
    end

    context 'when invalid' do
      it 'should return the do not play response' do
        champion_params = params['result']['parameters']
        champion_params['lane'] = 'Support'

        post action, params
        expect(speech).to eq controller.send(
          :do_not_play_response,
          champion_params['champion'],
          champion_params['lane']
        )[:speech]
      end
    end
  end

  describe 'POST lane' do
    let(:action) { :lane }

    context 'when valid' do
      it 'should indicate the strength of champions in the given lane' do
        post action, params

        expect(speech).to eq(
          "Jax  got better in the last patch and is currently ranked\n41 with a 49.69% win rate\nand a 3.76% play rate as a Top.\n"
        )
      end
    end

    context 'when invalid' do
      it 'should return the do not play response' do
        champion_params = params['result']['parameters']
        champion_params['lane'] = 'Support'

        post action, params
        expect(speech).to eq controller.send(
          :do_not_play_response,
          champion_params['champion'],
          champion_params['lane']
        )[:speech]
      end
    end
  end

  describe 'POST ability' do
    let(:action) { :ability }

    it "should describe the champion's ability" do
      post action, params

      expect(speech).to eq(
        "Ivern's second ability is called\nBrushmaker. In brush, Ivern's attacks are ranged and deal bonus magic damage. Ivern can activate this ability to create a patch of brush.\n"
      )
    end
  end

  describe 'POST cooldown' do
    let(:action) { :cooldown }

    it "should provide the champion's cooldown" do
      post action, params

      expect(speech).to eq(
        "Yasuo's fourth ability, Last Breath,\nhas a cooldown of 0 seconds at rank\n3.\n"
      )
    end
  end

  describe 'POST description' do
    let(:action) { :description }

    it 'should provide a description for the champion' do
      post action, params

      expect(speech).to eq(
        "Katarina, the the Sinister Blade, is a Assassin and Mage."
      )
    end
  end

  describe 'POST ally_tips' do
    let(:action) { :ally_tips }

    it 'should provide tips for playing the champion' do
      champion = RiotApi::RiotApi.get_champion('Fiora')
      allow(RiotApi::RiotApi).to receive(:get_champion).and_return(champion)
      allow(champion[:allytips]).to receive(:sample).and_return(
        champion[:allytips].last
      )
      post action, params

      expect(speech).to eq(
        "Here's a tip for playing as Fiora:\nGrand Challenge allows Fiora to take down even the most durable opponents and then recover if successful, so do not hesitate to attack the enemy's front line.\n"
      )
    end
  end

  describe 'POST enemy_tips' do
    let(:action) { :enemy_tips }

    it 'should provide tips for beating the enemy champion' do
      champion = RiotApi::RiotApi.get_champion('Leblanc')
      allow(RiotApi::RiotApi).to receive(:get_champion).and_return(champion)
      allow(champion[:enemytips]).to receive(:sample).and_return(
        champion[:enemytips].last
      )
      post action, params

      expect(speech).to eq(
        "\"Here's a tip for playing against LeBlanc:\nStunning or silencing LeBlanc will prevent her from activating the return part of Distortion.\"\n"
      )
    end
  end
end
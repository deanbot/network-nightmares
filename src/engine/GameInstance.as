package engine
{
	public class GameInstance
	{
		public static const DIFFICULTY_EASY:uint = 0;
		public static const DIFFICULTY_MEDIUM:uint = 1;
		public static const DIFFICULTY_HARD:uint = 2;
		public static var difficulty:uint = DIFFICULTY_MEDIUM;
		public static var lives:Number = 3;
		public static var level:uint = 1;
		public static var points:Number = 0;
		
		public static function get adminHealingTime():uint
		{
			var time:uint;
			switch(difficulty)
			{
				case DIFFICULTY_EASY:
					time=3200;
					break;
				case DIFFICULTY_MEDIUM:
					time=3000;
					break;
				case DIFFICULTY_HARD:
					time=2200;
					break;
			}
			return time;
		}
		
		public static function get adminWanderSpeed():Number
		{
			var speed:Number;
			switch(difficulty)
			{
				case DIFFICULTY_EASY:
					speed=80;
					break;
				case DIFFICULTY_MEDIUM:
					speed=100;
					break;
				case DIFFICULTY_HARD:
					speed=150;
					break;
			}
			return speed;
		}
		
		public static function get adminAlertSpeed():Number
		{
			var speed:Number;
			switch(difficulty)
			{
				case DIFFICULTY_EASY:
					speed=140;
					break;
				case DIFFICULTY_MEDIUM:
					speed=160;
					break;
				case DIFFICULTY_HARD:
					speed=200;
					break;
			}
			return speed;
		}
		
		public static function get virusAwardsTimeConstant():Number
		{
			var constant:Number;
			switch(difficulty)
			{
				case DIFFICULTY_EASY:
					constant=.6;
					break;
				case DIFFICULTY_MEDIUM:
					constant=.28;
					break;
				case DIFFICULTY_HARD:
					constant=.25;
					break;
			}
			return constant;
		}
	}
}
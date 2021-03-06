/******************************************************************************
 * Spine Runtimes Software License
 * Version 2.3
 * 
 * Copyright (c) 2013-2015, Esoteric Software
 * All rights reserved.
 * 
 * You are granted a perpetual, non-exclusive, non-sublicensable and
 * non-transferable license to use, install, execute and perform the Spine
 * Runtimes Software (the "Software") and derivative works solely for personal
 * or internal use. Without the written permission of Esoteric Software (see
 * Section 2 of the Spine Software License Agreement), you may not (a) modify,
 * translate, adapt or otherwise create derivative works, improvements of the
 * Software or develop new applications using the Software or (b) remove,
 * delete, alter or obscure any trademarks or any copyright, trademark, patent
 * or other intellectual property or proprietary rights notices on or in the
 * Software, including any copy thereof. Redistributions in binary or source
 * form must include this license and terms.
 * 
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

package spine.animation {
import spine.Bone;
import spine.Event;
import spine.Skeleton;

public class RotateTimeline extends CurveTimeline {
	static public const ENTRIES:int = 2;
	static private const PREV_TIME:int = -2, PREV_ROTATION:int = -1;
	static private const ROTATION:int = 1;

	public var boneIndex:int;
	public var frames:Vector.<Number>; // time, value, ...

	public function RotateTimeline (frameCount:int) {
		super(frameCount);
		frames = new Vector.<Number>(frameCount * 2, true);
	}

	/** Sets the time and angle of the specified keyframe. */
	public function setFrame (frameIndex:int, time:Number, degrees:Number) : void {
		frameIndex <<= 1;
		frames[frameIndex] = time;
		frames[int(frameIndex + ROTATION)] = degrees;
	}

	override public function apply (skeleton:Skeleton, lastTime:Number, time:Number, firedEvents:Vector.<Event>, alpha:Number) : void {
		if (time < frames[0])
			return; // Time is before first frame.

		var bone:Bone = skeleton.bones[boneIndex];
		
		if (time >= frames[int(frames.length - 2)]) { // Time is after last frame.
			var amount:Number = bone.data.rotation + frames[int(frames.length + PREV_ROTATION)] - bone.rotation;
			while (amount > 180)
				amount -= 360;
			while (amount < -180)
				amount += 360;
			bone.rotation += amount * alpha;
			return;
		}

		// Interpolate between the previous frame and the current frame.
		var frame:int = Animation.binarySearch(frames, time, ENTRIES);
		var prevRotation:Number = frames[int(frame + PREV_ROTATION)];
		var frameTime:Number = frames[frame];		
		var percent:Number = getCurvePercent((frame >> 1) - 1, 1 - (time - frameTime) / (frames[frame + PREV_TIME] - frameTime));

		amount = frames[int(frame + ROTATION)] - prevRotation;
		while (amount > 180)
			amount -= 360;
		while (amount < -180)
			amount += 360;
		amount = bone.data.rotation + (prevRotation + amount * percent) - bone.rotation;
		while (amount > 180)
			amount -= 360;
		while (amount < -180)
			amount += 360;
		bone.rotation += amount * alpha;
	}
}

}
